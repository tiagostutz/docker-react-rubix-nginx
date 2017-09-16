FROM nginx

RUN apt-get update
RUN apt-get install -qq curl
RUN apt-get install -qq git

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.3.1

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz"

RUN tar -zxvf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
&& rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
&& ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN npm install -g bower

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
RUN rm -rf dist || true
ONBUILD COPY ./package.json /usr/src/app
ONBUILD RUN npm install
ONBUILD COPY ./bower.json /usr/src/app
ONBUILD COPY ./.bowerrc /usr/src/app
ONBUILD RUN bower install --allow-root

ONBUILD COPY ./public /usr/src/app/public
ONBUILD COPY ./sass /usr/src/app/sass
ONBUILD COPY ./src /usr/src/app/src
ONBUILD COPY ./tools /usr/src/app/tools
ONBUILD COPY ./views /usr/src/app/views
ONBUILD COPY ./bower.json /usr/src/app/bower.json
ONBUILD COPY ./.bowerrc /usr/src/app/.bowerrc
ONBUILD COPY ./.babelrc /usr/src/app/.babelrc

ONBUILD RUN npm run dist -s

ONBUILD RUN rm -rf /usr/share/nginx/html/* || true
ONBUILD RUN chmod -R 777 ./dist/*
ONBUILD RUN cp -r ./dist/* /usr/share/nginx/html/

COPY ./nginx.conf /etc/nginx/nginx.conf
