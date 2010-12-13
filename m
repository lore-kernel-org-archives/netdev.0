From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/5] ifb: remove function declarations
Date: Mon, 13 Dec 2010 22:43:30 +0800
Message-ID: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53375 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab0LMOoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 09:44:04 -0500
Received: by yxt3 with SMTP id 3so3282598yxt.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 06:44:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restructure to remove function declarations.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |   51 +++++++++++++++++++++++----------------------------
 1 file changed, 23 insertions(+), 28 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index bfa03db..0667a61 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -46,11 +46,6 @@ struct ifb_private {
 
 static int numifbs = 2;
 
-static void ri_tasklet(unsigned long dev);
-static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev);
-static int ifb_open(struct net_device *dev);
-static int ifb_close(struct net_device *dev);
-
 static void ri_tasklet(unsigned long dev)
 {
 
@@ -119,29 +114,6 @@ resched:
 
 }
 
-static const struct net_device_ops ifb_netdev_ops = {
-	.ndo_open	= ifb_open,
-	.ndo_stop	= ifb_close,
-	.ndo_start_xmit	= ifb_xmit,
-	.ndo_validate_addr = eth_validate_addr,
-};
-
-static void ifb_setup(struct net_device *dev)
-{
-	/* Initialize the device structure. */
-	dev->destructor = free_netdev;
-	dev->netdev_ops = &ifb_netdev_ops;
-
-	/* Fill in device structure with ethernet-generic values. */
-	ether_setup(dev);
-	dev->tx_queue_len = TX_Q_LIMIT;
-
-	dev->flags |= IFF_NOARP;
-	dev->flags &= ~IFF_MULTICAST;
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
-	random_ether_addr(dev->dev_addr);
-}
-
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
@@ -193,6 +165,29 @@ static int ifb_open(struct net_device *dev)
 	return 0;
 }
 
+static const struct net_device_ops ifb_netdev_ops = {
+	.ndo_open		= ifb_open,
+	.ndo_stop		= ifb_close,
+	.ndo_start_xmit		= ifb_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static void ifb_setup(struct net_device *dev)
+{
+	/* Initialize the device structure. */
+	dev->destructor = free_netdev;
+	dev->netdev_ops = &ifb_netdev_ops;
+
+	/* Fill in device structure with ethernet-generic values. */
+	ether_setup(dev);
+	dev->tx_queue_len = TX_Q_LIMIT;
+
+	dev->flags |= IFF_NOARP;
+	dev->flags &= ~IFF_MULTICAST;
+	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	random_ether_addr(dev->dev_addr);
+}
+
 static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
