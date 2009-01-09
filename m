From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 19/45] 3c523: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:16 -0800
Message-ID: <20090109230138.115123292@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42195 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754079AbZAIXR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:56 -0500
Content-Disposition: inline; filename=3c523.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c523.c	2009-01-08 10:26:03.174260274 -0800
+++ b/drivers/net/3c523.c	2009-01-08 10:29:23.344995792 -0800
@@ -403,6 +403,20 @@ static int elmc_getinfo(char *buf, int s
 	return len;
 }				/* elmc_getinfo() */
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open 		= elmc_open,
+	.ndo_stop		= elmc_close,
+	.ndo_get_stats		= elmc_get_stats,
+	.ndo_start_xmit		= elmc_send_packet,
+	.ndo_tx_timeout		= elmc_timeout,
+#ifdef ELMC_MULTICAST
+	.ndo_set_multicast_list = set_multicast_list,
+#endif
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*****************************************************************/
 
 static int __init do_elmc_probe(struct net_device *dev)
@@ -544,17 +558,8 @@ static int __init do_elmc_probe(struct n
 	printk(KERN_INFO "%s: hardware address %pM\n",
 	       dev->name, dev->dev_addr);
 
-	dev->open = &elmc_open;
-	dev->stop = &elmc_close;
-	dev->get_stats = &elmc_get_stats;
-	dev->hard_start_xmit = &elmc_send_packet;
-	dev->tx_timeout = &elmc_timeout;
+	dev->netdev_ops = &netdev_ops;
 	dev->watchdog_timeo = HZ;
-#ifdef ELMC_MULTICAST
-	dev->set_multicast_list = &set_multicast_list;
-#else
-	dev->set_multicast_list = NULL;
-#endif
 	dev->ethtool_ops = &netdev_ethtool_ops;
 
 	/* note that we haven't actually requested the IRQ from the kernel.


