From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 25/30] netdev: convert ni52 to net_device_ops
Date: Thu, 26 Mar 2009 18:11:39 -0700
Message-ID: <20090327011256.744935038@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46961 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763242AbZC0Bel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:34:41 -0400
Content-Disposition: inline; filename=ni52.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ni52.c	2009-03-21 12:36:59.000000000 -0700
+++ b/drivers/net/ni52.c	2009-03-26 16:52:45.793350549 -0700
@@ -441,6 +441,18 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops ni52_netdev_ops = {
+	.ndo_open		= ni52_open,
+	.ndo_stop		= ni52_close,
+	.ndo_get_stats		= ni52_get_stats,
+	.ndo_tx_timeout 	= ni52_timeout,
+	.ndo_start_xmit 	= ni52_send_packet,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, size, retval;
@@ -561,15 +573,8 @@ static int __init ni52_probe1(struct net
 		printk("IRQ %d (assigned and not checked!).\n", dev->irq);
 	}
 
-	dev->open		= ni52_open;
-	dev->stop		= ni52_close;
-	dev->get_stats		= ni52_get_stats;
-	dev->tx_timeout 	= ni52_timeout;
+	dev->netdev_ops		= &ni52_netdev_ops;
 	dev->watchdog_timeo	= HZ/20;
-	dev->hard_start_xmit 	= ni52_send_packet;
-	dev->set_multicast_list = set_multicast_list;
-
-	dev->if_port 		= 0;
 
 	return 0;
 out:


