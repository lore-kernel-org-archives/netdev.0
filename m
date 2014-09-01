From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/9] net: xmit_list() becomes dev_hard_start_xmit().
Date: Mon, 01 Sep 2014 15:25:18 -0700 (PDT)
Message-ID: <20140901.152518.1301582066532637736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbaIAWZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:25:18 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 569A359086D
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:25:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now fundamentally we can process lists of SKBs as cheaply
as single packets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c89da4f..6857d57 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2570,8 +2570,8 @@ static int xmit_one(struct sk_buff *skb, struct net_device *dev,
 	return rc;
 }
 
-static struct sk_buff *xmit_list(struct sk_buff *first, struct net_device *dev,
-				 struct netdev_queue *txq, int *ret)
+struct sk_buff *dev_hard_start_xmit(struct sk_buff *first, struct net_device *dev,
+				    struct netdev_queue *txq, int *ret)
 {
 	struct sk_buff *skb = first;
 	int rc = NETDEV_TX_OK;
@@ -2673,17 +2673,6 @@ out_null:
 	return NULL;
 }
 
-struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-				    struct netdev_queue *txq, int *ret)
-{
-	if (likely(!skb->next)) {
-		*ret = xmit_one(skb, dev, txq, false);
-		return skb;
-	}
-
-	return xmit_list(skb, dev, txq, ret);
-}
-
 static void qdisc_pkt_len_init(struct sk_buff *skb)
 {
 	const struct skb_shared_info *shinfo = skb_shinfo(skb);
-- 
1.7.11.7
