From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/33] veth: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:15 -0800
Message-ID: <20081117234355.458484432@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55054 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792AbYKRAAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:01 -0500
Content-Disposition: inline; filename=veth-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops function tabl.e

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/veth.c	2008-11-17 10:27:34.000000000 -0800
+++ b/drivers/net/veth.c	2008-11-17 10:28:30.000000000 -0800
@@ -262,16 +262,20 @@ static void veth_dev_free(struct net_dev
 	free_netdev(dev);
 }
 
+static const struct net_device_ops veth_netdev_ops = {
+	.init	   = veth_dev_init,
+	.open	   = veth_open,
+	.get_stats = veth_get_stats,
+};
+
 static void veth_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
+	dev->netdev_ops = &veth_netdev_ops;
 	dev->hard_start_xmit = veth_xmit;
-	dev->get_stats = veth_get_stats;
-	dev->open = veth_open;
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
-	dev->init = veth_dev_init;
 	dev->destructor = veth_dev_free;
 }
 
@@ -297,7 +301,7 @@ static int veth_device_event(struct noti
 {
 	struct net_device *dev = ptr;
 
-	if (dev->open != veth_open)
+	if (dev->netdev_ops->open != veth_open)
 		goto out;
 
 	switch (event) {

-- 

