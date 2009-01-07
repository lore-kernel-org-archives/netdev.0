From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 26/42] de4x5: convert to net_device_ops
Date: Tue, 06 Jan 2009 16:33:42 -0800
Message-ID: <20090107003348.293324488@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52739 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757616AbZAGA7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:59:16 -0500
Content-Disposition: inline; filename=tulip-de2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tulip/de4x5.c	2009-01-06 16:08:31.193364166 -0800
+++ b/drivers/net/tulip/de4x5.c	2009-01-06 16:13:50.841110201 -0800
@@ -1077,6 +1077,18 @@ static int (*dc_infoblock[])(struct net_
     mdelay(2);                           /* Wait for 2ms */\
 }
 
+static const struct net_device_ops de4x5_netdev_ops = {
+    .ndo_open		= de4x5_open,
+    .ndo_stop		= de4x5_close,
+    .ndo_start_xmit	= de4x5_queue_pkt,
+    .ndo_get_stats	= de4x5_get_stats,
+    .ndo_set_multicast_list = set_multicast_list,
+    .ndo_do_ioctl	= de4x5_ioctl,
+    .ndo_change_mtu	= eth_change_mtu,
+    .ndo_set_mac_address= eth_mac_addr,
+    .ndo_validate_addr	= eth_validate_addr,
+};
+
 
 static int __devinit
 de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
@@ -1258,13 +1270,7 @@ de4x5_hw_init(struct net_device *dev, u_
 
     /* The DE4X5-specific entries in the device structure. */
     SET_NETDEV_DEV(dev, gendev);
-    dev->open = &de4x5_open;
-    dev->hard_start_xmit = &de4x5_queue_pkt;
-    dev->stop = &de4x5_close;
-    dev->get_stats = &de4x5_get_stats;
-    dev->set_multicast_list = &set_multicast_list;
-    dev->do_ioctl = &de4x5_ioctl;
-
+    dev->netdev_ops = &de4x5_netdev_ops;
     dev->mem_start = 0;
 
     /* Fill in the generic fields of the device structure. */

-- 

