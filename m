From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/33] netdev: convert loopback to net_device_ops
Date: Mon, 17 Nov 2008 15:42:11 -0800
Message-ID: <20081117234355.119908838@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55043 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962AbYKQX76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:59:58 -0500
Content-Disposition: inline; filename=loopback-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First device to convert over is the loopback device.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/loopback.c	2008-11-17 12:21:00.000000000 -0800
+++ b/drivers/net/loopback.c	2008-11-17 12:28:45.000000000 -0800
@@ -87,7 +87,7 @@ static int loopback_xmit(struct sk_buff 
 	return 0;
 }
 
-static struct net_device_stats *get_stats(struct net_device *dev)
+static struct net_device_stats *loopback_get_stats(struct net_device *dev)
 {
 	const struct pcpu_lstats *pcpu_lstats;
 	struct net_device_stats *stats = &dev->stats;
@@ -143,13 +143,17 @@ static void loopback_dev_free(struct net
 	free_netdev(dev);
 }
 
+static const struct net_device_ops loopback_ops = {
+	.init      = loopback_dev_init,
+	.get_stats = loopback_get_stats,
+};
+
 /*
  * The loopback device is special. There is only one instance
  * per network namespace.
  */
 static void loopback_setup(struct net_device *dev)
 {
-	dev->get_stats		= &get_stats;
 	dev->mtu		= (16 * 1024) + 20 + 20 + 12;
 	dev->hard_start_xmit	= loopback_xmit;
 	dev->hard_header_len	= ETH_HLEN;	/* 14	*/
@@ -165,8 +169,8 @@ static void loopback_setup(struct net_de
 		| NETIF_F_NETNS_LOCAL;
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
-	dev->init = loopback_dev_init;
-	dev->destructor = loopback_dev_free;
+	dev->netdev_ops		= &loopback_ops;
+	dev->destructor		= loopback_dev_free;
 }
 
 /* Setup and register the loopback device. */

-- 

