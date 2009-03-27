From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 18/30] lance: convert to net_device_ops
Date: Thu, 26 Mar 2009 18:11:32 -0700
Message-ID: <20090327011256.246914829@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49174 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761503AbZC0Ba7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:30:59 -0400
Content-Disposition: inline; filename=lance.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/lance.c	2009-03-21 12:36:59.000000000 -0700
+++ b/drivers/net/lance.c	2009-03-26 16:10:50.486599761 -0700
@@ -454,6 +454,18 @@ out:
 }
 #endif
 
+static const struct net_device_ops lance_netdev_ops = {
+	.ndo_open 		= lance_open,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_stop		= lance_close,
+	.ndo_get_stats		= lance_get_stats,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_tx_timeout		= lance_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int options)
 {
 	struct lance_private *lp;
@@ -714,12 +726,7 @@ static int __init lance_probe1(struct ne
 		printk(version);
 
 	/* The LANCE-specific entries in the device structure. */
-	dev->open = lance_open;
-	dev->hard_start_xmit = lance_start_xmit;
-	dev->stop = lance_close;
-	dev->get_stats = lance_get_stats;
-	dev->set_multicast_list = set_multicast_list;
-	dev->tx_timeout = lance_tx_timeout;
+	dev->netdev_ops = &lance_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	err = register_netdev(dev);


