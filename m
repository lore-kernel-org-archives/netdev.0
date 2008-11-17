From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 30/33] tg3: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:37 -0800
Message-ID: <20081117234357.345529638@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55120 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312AbYKRAAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:22 -0500
Content-Disposition: inline; filename=tg3-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tg3.c	2008-11-17 14:03:52.000000000 -0800
+++ b/drivers/net/tg3.c	2008-11-17 14:45:38.000000000 -0800
@@ -13343,6 +13343,22 @@ static void __devinit tg3_init_coal(stru
 	}
 }
 
+static const struct net_device_ops tg3_netdev_ops = {
+	.open			= tg3_open,
+	.stop			= tg3_close,
+	.get_stats		= tg3_get_stats,
+	.validate_addr		= eth_validate_addr,
+	.set_multicast_list	= tg3_set_rx_mode,
+	.set_mac_address	= tg3_set_mac_addr,
+	.do_ioctl		= tg3_ioctl,
+	.tx_timeout		= tg3_tx_timeout,
+	.change_mtu		= tg3_change_mtu,
+	.vlan_rx_register	= tg3_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= tg3_poll_controller,
+#endif
+};
+
 static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -13400,7 +13416,6 @@ static int __devinit tg3_init_one(struct
 
 #if TG3_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = tg3_vlan_rx_register;
 #endif
 
 	tp = netdev_priv(dev);
@@ -13458,21 +13473,11 @@ static int __devinit tg3_init_one(struct
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 	tp->tx_pending = TG3_DEF_TX_RING_PENDING;
 
-	dev->open = tg3_open;
-	dev->stop = tg3_close;
-	dev->get_stats = tg3_get_stats;
-	dev->set_multicast_list = tg3_set_rx_mode;
-	dev->set_mac_address = tg3_set_mac_addr;
-	dev->do_ioctl = tg3_ioctl;
-	dev->tx_timeout = tg3_tx_timeout;
+	dev->netdev_ops = &tg3_netdev_ops;
 	netif_napi_add(dev, &tp->napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
-	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = tg3_poll_controller;
-#endif
 
 	err = tg3_get_invariants(tp);
 	if (err) {

-- 

