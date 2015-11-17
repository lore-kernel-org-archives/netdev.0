From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/9] net: un-inline sk_busy_loop()
Date: Tue, 17 Nov 2015 06:15:51 -0800
Message-ID: <1447769751.22599.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447768624-14962-1-git-send-email-edumazet@google.com>
	 <1447768624-14962-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35645 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbbKQOPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:15:54 -0500
Received: by pacej9 with SMTP id ej9so10343406pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 06:15:54 -0800 (PST)
In-Reply-To: <1447768624-14962-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 05:56 -0800, Eric Dumazet wrote:
> There is really little gain from inlining this big function.
> We'll soon make it even bigger in following patches.

I forgot to guard sk_busy_poll() with appropriate #ifdef :

This will be added in v2

diff --git a/net/core/dev.c b/net/core/dev.c
index 21a7d4093fde..c87c8486ea21 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4673,6 +4673,7 @@ static struct napi_struct *napi_by_id(unsigned int napi_id)
 	return NULL;
 }
 
+#if defined(CONFIG_NET_RX_BUSY_POLL)
 #define BUSY_POLL_BUDGET 8
 bool sk_busy_loop(struct sock *sk, int nonblock)
 {
@@ -4726,6 +4727,7 @@ out:
 	return rc;
 }
 EXPORT_SYMBOL(sk_busy_loop);
+#endif
 
 void napi_hash_add(struct napi_struct *napi)
 {
