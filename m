From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/5] ifb: code cleanup
Date: Mon, 13 Dec 2010 22:43:31 +0800
Message-ID: <1292251414-5154-2-git-send-email-xiaosuo@gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53375 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab0LMOoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 09:44:13 -0500
Received: by mail-yx0-f174.google.com with SMTP id 3so3282598yxt.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 06:44:13 -0800 (PST)
In-Reply-To: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up code according to scripts/checkpatch.pl

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |   22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 0667a61..1628d01 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -15,14 +15,14 @@
 	by Patrick McHardy and then maintained by Andre Correa.
 
 	You need the tc action  mirror or redirect to feed this device
-       	packets.
+	packets.
 
 	This program is free software; you can redistribute it and/or
 	modify it under the terms of the GNU General Public License
 	as published by the Free Software Foundation; either version
 	2 of the License, or (at your option) any later version.
 
-  	Authors:	Jamal Hadi Salim (2005)
+	Authors:	Jamal Hadi Salim (2005)
 
 */
 
@@ -56,7 +56,8 @@ static void ri_tasklet(unsigned long dev)
 	struct sk_buff *skb;
 
 	txq = netdev_get_tx_queue(_dev, 0);
-	if ((skb = skb_peek(&dp->tq)) == NULL) {
+	skb = skb_peek(&dp->tq);
+	if (skb == NULL) {
 		if (__netif_tx_trylock(txq)) {
 			skb_queue_splice_tail_init(&dp->rq, &dp->tq);
 			__netif_tx_unlock(txq);
@@ -72,7 +73,7 @@ static void ri_tasklet(unsigned long dev)
 		skb->tc_verd = 0;
 		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
 		stats->tx_packets++;
-		stats->tx_bytes +=skb->len;
+		stats->tx_bytes += skb->len;
 
 		rcu_read_lock();
 		skb->dev = dev_get_by_index_rcu(&init_net, skb->skb_iif);
@@ -97,7 +98,8 @@ static void ri_tasklet(unsigned long dev)
 	}
 
 	if (__netif_tx_trylock(txq)) {
-		if ((skb = skb_peek(&dp->rq)) == NULL) {
+		skb = skb_peek(&dp->rq);
+		if (skb == NULL) {
 			dp->tasklet_pending = 0;
 			if (netif_queue_stopped(_dev))
 				netif_wake_queue(_dev);
@@ -121,7 +123,7 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 from = G_TC_FROM(skb->tc_verd);
 
 	stats->rx_packets++;
-	stats->rx_bytes+=skb->len;
+	stats->rx_bytes += skb->len;
 
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
 		dev_kfree_skb(skb);
@@ -129,9 +131,8 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len) {
+	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len)
 		netif_stop_queue(dev);
-	}
 
 	__skb_queue_tail(&dp->rq, skb);
 	if (!dp->tasklet_pending) {
@@ -150,6 +151,7 @@ static int ifb_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	__skb_queue_purge(&dp->rq);
 	__skb_queue_purge(&dp->tq);
+
 	return 0;
 }
 
@@ -196,6 +198,7 @@ static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
+
 	return 0;
 }
 
@@ -215,8 +218,7 @@ static int __init ifb_init_one(int index)
 	struct net_device *dev_ifb;
 	int err;
 
-	dev_ifb = alloc_netdev(sizeof(struct ifb_private),
-				 "ifb%d", ifb_setup);
+	dev_ifb = alloc_netdev(sizeof(struct ifb_private), "ifb%d", ifb_setup);
 
 	if (!dev_ifb)
 		return -ENOMEM;
