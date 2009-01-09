From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 18/45] 3c515: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:15 -0800
Message-ID: <20090109230138.042873118@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42194 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754030AbZAIXR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:56 -0500
Content-Disposition: inline; filename=3c515.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c515.c	2009-01-08 10:24:08.314256647 -0800
+++ b/drivers/net/3c515.c	2009-01-08 10:25:46.944777264 -0800
@@ -563,6 +563,20 @@ no_pnp:
 	return NULL;
 }
 
+
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= corkscrew_open,
+	.ndo_stop		= corkscrew_close,
+	.ndo_start_xmit		= corkscrew_start_xmit,
+	.ndo_tx_timeout		= corkscrew_timeout,
+	.ndo_get_stats		= corkscrew_get_stats,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+
 static int corkscrew_setup(struct net_device *dev, int ioaddr,
 			    struct pnp_dev *idev, int card_number)
 {
@@ -681,13 +695,8 @@ static int corkscrew_setup(struct net_de
 	vp->full_bus_master_rx = (vp->capabilities & 0x20) ? 1 : 0;
 
 	/* The 3c51x-specific entries in the device structure. */
-	dev->open = &corkscrew_open;
-	dev->hard_start_xmit = &corkscrew_start_xmit;
-	dev->tx_timeout = &corkscrew_timeout;
+	dev->netdev_ops = &netdev_ops;
 	dev->watchdog_timeo = (400 * HZ) / 1000;
-	dev->stop = &corkscrew_close;
-	dev->get_stats = &corkscrew_get_stats;
-	dev->set_multicast_list = &set_rx_mode;
 	dev->ethtool_ops = &netdev_ethtool_ops;
 
 	return register_netdev(dev);


