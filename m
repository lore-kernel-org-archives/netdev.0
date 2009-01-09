From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 20/45] 3c527: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:17 -0800
Message-ID: <20090109230138.187195860@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42196 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754145AbZAIXR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:57 -0500
Content-Disposition: inline; filename=3c527.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c527.c	2009-01-08 10:27:52.851007199 -0800
+++ b/drivers/net/3c527.c	2009-01-08 10:29:08.786256455 -0800
@@ -288,6 +288,18 @@ struct net_device *__init mc32_probe(int
 	return ERR_PTR(-ENODEV);
 }
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= mc32_open,
+	.ndo_stop		= mc32_close,
+	.ndo_start_xmit		= mc32_send_packet,
+	.ndo_get_stats		= mc32_get_stats,
+	.ndo_set_multicast_list = mc32_set_multicast_list,
+	.ndo_tx_timeout		= mc32_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /**
  * mc32_probe1	-	Check a given slot for a board and test the card
  * @dev:  Device structure to fill in
@@ -518,12 +530,7 @@ static int __init mc32_probe1(struct net
 	printk("%s: Firmware Rev %d. %d RX buffers, %d TX buffers. Base of 0x%08X.\n",
 		dev->name, lp->exec_box->data[12], lp->rx_len, lp->tx_len, lp->base);
 
-	dev->open		= mc32_open;
-	dev->stop		= mc32_close;
-	dev->hard_start_xmit	= mc32_send_packet;
-	dev->get_stats		= mc32_get_stats;
-	dev->set_multicast_list = mc32_set_multicast_list;
-	dev->tx_timeout		= mc32_timeout;
+	dev->netdev_ops		= &netdev_ops;
 	dev->watchdog_timeo	= HZ*5;	/* Board does all the work */
 	dev->ethtool_ops	= &netdev_ethtool_ops;
 


