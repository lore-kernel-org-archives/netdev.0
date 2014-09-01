From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/9] net: Have xmit_list() signal more==true when
 appropriate.
Date: Mon, 01 Sep 2014 15:24:59 -0700 (PDT)
Message-ID: <20140901.152459.592105486574617399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:25:00 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C0448590920
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:24:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f0ed5a6..6d82194 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2600,7 +2600,7 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 EXPORT_SYMBOL(netif_skb_features);
 
 static int xmit_one(struct sk_buff *skb, struct net_device *dev,
-		    struct netdev_queue *txq)
+		    struct netdev_queue *txq, bool more)
 {
 	unsigned int len;
 	int rc;
@@ -2610,7 +2610,7 @@ static int xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	len = skb->len;
 	trace_net_dev_start_xmit(skb, dev);
-	rc = netdev_start_xmit(skb, dev, txq, false);
+	rc = netdev_start_xmit(skb, dev, txq, more);
 	trace_net_dev_xmit(skb, rc, dev, len);
 
 	return rc;
@@ -2626,7 +2626,7 @@ static struct sk_buff *xmit_list(struct sk_buff *first, struct net_device *dev,
 		struct sk_buff *next = skb->next;
 
 		skb->next = NULL;
-		rc = xmit_one(skb, dev, txq);
+		rc = xmit_one(skb, dev, txq, next != NULL);
 		if (unlikely(!dev_xmit_complete(rc))) {
 			skb->next = next;
 			goto out;
@@ -2705,7 +2705,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			}
 		}
 
-		return xmit_one(skb, dev, txq);
+		return xmit_one(skb, dev, txq, false);
 	}
 
 gso:
-- 
1.7.11.7
