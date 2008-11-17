From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/33] e1000e: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:20 -0800
Message-ID: <20081117234355.888854880@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55069 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962AbYKRAAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:08 -0500
Content-Disposition: inline; filename=e1000e-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert e1000e to network device ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/e1000e/netdev.c	2008-11-17 07:57:18.000000000 -0800
+++ b/drivers/net/e1000e/netdev.c	2008-11-17 10:25:30.000000000 -0800
@@ -4686,6 +4686,25 @@ static void e1000_eeprom_checks(struct e
 	}
 }
 
+static const struct net_device_ops e1000e_netdev_ops = {
+	.open			= e1000_open,
+	.stop			= e1000_close,
+	.get_stats		= e1000_get_stats,
+	.set_multicast_list	= e1000_set_multi,
+	.set_mac_address	= e1000_set_mac,
+	.change_mtu		= e1000_change_mtu,
+	.do_ioctl		= e1000_ioctl,
+	.tx_timeout		= e1000_tx_timeout,
+	.validate_addr		= eth_validate_addr,
+
+	.vlan_rx_register	= e1000_vlan_rx_register,
+	.vlan_rx_add_vid	= e1000_vlan_rx_add_vid,
+	.vlan_rx_kill_vid	= e1000_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= e1000_netpoll,
+#endif
+};
+
 /**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -4783,24 +4802,11 @@ static int __devinit e1000_probe(struct 
 	}
 
 	/* construct the net_device struct */
-	netdev->open			= &e1000_open;
-	netdev->stop			= &e1000_close;
+	netdev->netdev_ops		= &e1000e_netdev_ops;
 	netdev->hard_start_xmit		= &e1000_xmit_frame;
-	netdev->get_stats		= &e1000_get_stats;
-	netdev->set_multicast_list	= &e1000_set_multi;
-	netdev->set_mac_address		= &e1000_set_mac;
-	netdev->change_mtu		= &e1000_change_mtu;
-	netdev->do_ioctl		= &e1000_ioctl;
 	e1000e_set_ethtool_ops(netdev);
-	netdev->tx_timeout		= &e1000_tx_timeout;
 	netdev->watchdog_timeo		= 5 * HZ;
 	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
-	netdev->vlan_rx_register	= e1000_vlan_rx_register;
-	netdev->vlan_rx_add_vid		= e1000_vlan_rx_add_vid;
-	netdev->vlan_rx_kill_vid	= e1000_vlan_rx_kill_vid;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller		= e1000_netpoll;
-#endif
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	netdev->mem_start = mmio_start;

-- 

