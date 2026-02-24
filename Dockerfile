# ---- build frontend (react/vite) ----
FROM node:20-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- build backend (flask) ----
FROM python:3.11-slim AS backend
WORKDIR /app

# install python deps
COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt

# copy backend code
COPY backend backend

# copy built frontend dist to project root (so backend/app.py finds ../dist)
COPY --from=frontend /app/dist dist

# env
ENV PYTHONUNBUFFERED=1

# Railway provides $PORT at runtime
CMD ["sh", "-c", "gunicorn backend.app:app --bind 0.0.0.0:$PORT"]