From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 03/14] hp-plus: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:22 -0800
Message-ID: <20081126011545.427241802@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58788 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702AbYKZBSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:47 -0500
Content-Disposition: inline; filename=hp-plus.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another driver converted to new infrastructure.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hp-plus.c	2008-11-25 16:23:38.000000000 -0800
+++ b/drivers/net/hp-plus.c	2008-11-25 16:40:50.000000000 -0800
@@ -158,6 +158,21 @@ out:
 }
 #endif
 
+static const struct net_device_ops hpp_netdev_ops = {
+	.ndo_open		 = hpp_open,
+	.ndo_stop		 = hpp_close,
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller 	= ei_poll,
+#endif
+};
+
+
 /* Do the interesting part of the probe at a single address. */
 static int __init hpp_probe1(struct net_device *dev, int ioaddr)
 {
@@ -226,11 +241,7 @@ static int __init hpp_probe1(struct net_
 	/* Set the base address to point to the NIC, not the "real" base! */
 	dev->base_addr = ioaddr + NIC_OFFSET;
 
-	dev->open = &hpp_open;
-	dev->stop = &hpp_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+	dev->netdev_ops = &hpp_netdev_ops;
 
 	ei_status.name = name;
 	ei_status.word16 = 0;		/* Agggghhhhh! Debug time: 2 days! */
@@ -301,8 +312,7 @@ hpp_open(struct net_device *dev)
 	/* Select the operational page. */
 	outw(Perf_Page, ioaddr + HP_PAGING);
 
-	eip_open(dev);
-	return 0;
+	return eip_open(dev);
 }
 
 static int


