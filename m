From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 24/30] netdev: convert ewrk3 to net_device_ops
Date: Thu, 26 Mar 2009 18:11:38 -0700
Message-ID: <20090327011256.673661455@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49192 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763244AbZC0BeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:34:01 -0400
Content-Disposition: inline; filename=ewrk3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ewrk3.c	2009-03-26 16:40:30.657605085 -0700
+++ b/drivers/net/ewrk3.c	2009-03-26 16:41:14.530600117 -0700
@@ -388,6 +388,18 @@ static int __init ewrk3_probe1(struct ne
 	return err;
 }
 
+static const struct net_device_ops ewrk3_netdev_ops = {
+	.ndo_open		= ewrk3_open,
+	.ndo_start_xmit		= ewrk3_queue_pkt,
+	.ndo_stop		= ewrk3_close,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_do_ioctl		= ewrk3_ioctl,
+	.ndo_tx_timeout		= ewrk3_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init
 ewrk3_hw_init(struct net_device *dev, u_long iobase)
 {
@@ -603,16 +615,11 @@ ewrk3_hw_init(struct net_device *dev, u_
 		printk(version);
 	}
 	/* The EWRK3-specific entries in the device structure. */
-	dev->open = ewrk3_open;
-	dev->hard_start_xmit = ewrk3_queue_pkt;
-	dev->stop = ewrk3_close;
-	dev->set_multicast_list = set_multicast_list;
-	dev->do_ioctl = ewrk3_ioctl;
+	dev->netdev_ops = &ewrk3_netdev_ops;
 	if (lp->adapter_name[4] == '3')
 		SET_ETHTOOL_OPS(dev, &ethtool_ops_203);
 	else
 		SET_ETHTOOL_OPS(dev, &ethtool_ops);
-	dev->tx_timeout = ewrk3_timeout;
 	dev->watchdog_timeo = QUEUE_PKT_TIMEOUT;
 
 	dev->mem_start = 0;


