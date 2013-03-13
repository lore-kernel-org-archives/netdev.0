From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: when and where does ep_poll_callback be called ?
Date: Wed, 13 Mar 2013 06:00:52 +0100
Message-ID: <1363150852.13690.29.camel@edumazet-glaptop>
References: <20130114011115.GG2743@debian.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: horseriver <horserivers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:58479 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab3CMFA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 01:00:56 -0400
Received: by mail-ea0-f173.google.com with SMTP id h14so201120eak.4
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 22:00:55 -0700 (PDT)
In-Reply-To: <20130114011115.GG2743@debian.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 09:11 +0800, horseriver wrote:
> hi:
> 
> 
>    I'm studying the epoll module , I can not find ep_poll_callback be called somewhere .
>    
>   

Thats more a lkml question.

But you can figure it yourself :

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 9fec183..c6e7490 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -928,6 +928,7 @@ static int ep_poll_callback(wait_queue_t *wait, unsigned mode, int sync, void *k
 	struct epitem *epi = ep_item_from_wait(wait);
 	struct eventpoll *ep = epi->ep;
 
+	WARN_ON_ONCE(1);
 	if ((unsigned long)key & POLLFREE) {
 		ep_pwq_from_wait(wait)->whead = NULL;
 		/*
