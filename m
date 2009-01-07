From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 42/42] b44: convert to net_device_ops
Date: Tue, 06 Jan 2009 16:33:58 -0800
Message-ID: <20090107003349.987938173@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60730 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757131AbZAGAyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:18 -0500
Content-Disposition: inline; filename=b44.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/b44.c	2009-01-06 14:16:03.441860786 -0800
+++ b/drivers/net/b44.c	2009-01-06 14:29:04.120610422 -0800
@@ -2108,6 +2108,22 @@ static int __devinit b44_get_invariants(
 	return err;
 }
 
+static const struct net_device_ops b44_netdev_ops = {
+	.ndo_open		= b44_open,
+	.ndo_stop		= b44_close,
+	.ndo_start_xmit		= b44_start_xmit,
+	.ndo_get_stats		= b44_get_stats,
+	.ndo_set_multicast_list = b44_set_rx_mode,
+	.ndo_set_mac_address	= b44_set_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= b44_ioctl,
+	.ndo_tx_timeout		= b44_tx_timeout,
+	.ndo_change_mtu		= b44_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= b44_poll_controller,
+#endif
+};
+
 static int __devinit b44_init_one(struct ssb_device *sdev,
 				  const struct ssb_device_id *ent)
 {
@@ -2145,20 +2161,9 @@ static int __devinit b44_init_one(struct
 	bp->rx_pending = B44_DEF_RX_RING_PENDING;
 	bp->tx_pending = B44_DEF_TX_RING_PENDING;
 
-	dev->open = b44_open;
-	dev->stop = b44_close;
-	dev->hard_start_xmit = b44_start_xmit;
-	dev->get_stats = b44_get_stats;
-	dev->set_multicast_list = b44_set_rx_mode;
-	dev->set_mac_address = b44_set_mac_addr;
-	dev->do_ioctl = b44_ioctl;
-	dev->tx_timeout = b44_tx_timeout;
+	dev->netdev_ops = &b44_netdev_ops;
 	netif_napi_add(dev, &bp->napi, b44_poll, 64);
 	dev->watchdog_timeo = B44_TX_TIMEOUT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = b44_poll_controller;
-#endif
-	dev->change_mtu = b44_change_mtu;
 	dev->irq = sdev->irq;
 	SET_ETHTOOL_OPS(dev, &b44_ethtool_ops);
 

-- 

