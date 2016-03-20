From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: remove a dubious unlikely() clause
Date: Sun, 20 Mar 2016 11:27:47 -0700
Message-ID: <1458498467.10868.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33853 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbcCTS1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 14:27:50 -0400
Received: by mail-pf0-f174.google.com with SMTP id x3so237206268pfb.1
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2016 11:27:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP protocol is still used these days, and TCP uses
clones in its transmit path. We can not optimize linux
stack assuming it is mostly used in routers, or that TCP
is dead.

Fixes: 795bb1c00d ("net: bulk free infrastructure for NAPI context, use napi_consume_skb")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/skbuff.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f044f97..d04c2d1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -815,7 +815,7 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
 	trace_consume_skb(skb);
 
 	/* if SKB is a clone, don't handle this case */
-	if (unlikely(skb->fclone != SKB_FCLONE_UNAVAILABLE)) {
+	if (skb->fclone != SKB_FCLONE_UNAVAILABLE) {
 		__kfree_skb(skb);
 		return;
 	}
