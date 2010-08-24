From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: use skb_get_rxhash()
Date: Tue, 24 Aug 2010 17:52:38 +0800
Message-ID: <1282643558-20866-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65367 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab0HXJxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 05:53:35 -0400
Received: by pvg2 with SMTP id 2so2586830pvg.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 02:53:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although it is rare the line contains skb->rxhash is executed:

 * The forwarded skbs should have the the rx queue recoreded.
 * The local generated skbs should have non zero sk_hash in most of cases.

when it is executed, a non zero rxhash will be better.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index 859e30f..ea041fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2034,7 +2034,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
-		hash = (__force u16) skb->protocol ^ skb->rxhash;
+		hash = (__force u16) skb->protocol ^ skb_get_rxhash(skb);
 	hash = jhash_1word(hash, hashrnd);
 
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
