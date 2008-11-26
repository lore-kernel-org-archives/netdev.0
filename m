From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 13/14] 3c503: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:32 -0800
Message-ID: <20081126011546.177282169@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55269 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbYKZBS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:56 -0500
Content-Disposition: inline; filename=3c503-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another of the 8390p group.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c503.c	2008-11-25 14:47:36.000000000 -0800
+++ b/drivers/net/3c503.c	2008-11-25 17:04:58.000000000 -0800
@@ -168,6 +168,21 @@ out:
 }
 #endif
 
+static const struct net_device_ops el2_netdev_ops = {
+	.ndo_open		= el2_open,
+	.ndo_stop		= el2_close,
+
+	.ndo_start_xmit		= eip_start_xmit,
+	.ndo_tx_timeout		= eip_tx_timeout,
+	.ndo_get_stats		= eip_get_stats,
+	.ndo_set_multicast_list = eip_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller 	= eip_poll,
+#endif
+};
+
 /* Probe for the Etherlink II card at I/O port base IOADDR,
    returning non-zero on success.  If found, set the station
    address and memory parameters in DEVICE. */
@@ -335,8 +350,7 @@ el2_probe1(struct net_device *dev, int i
 
     ei_status.saved_irq = dev->irq;
 
-    dev->open = &el2_open;
-    dev->stop = &el2_close;
+    dev->netdev_ops = &el2_netdev_ops;
     dev->ethtool_ops = &netdev_ethtool_ops;
 #ifdef CONFIG_NET_POLL_CONTROLLER
     dev->poll_controller = eip_poll;


