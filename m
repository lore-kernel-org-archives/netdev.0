From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 29/33] ixgb: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:36 -0800
Message-ID: <20081117234357.262431493@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55117 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366AbYKRAAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:21 -0500
Content-Disposition: inline; filename=ixgb-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ixgb/ixgb_main.c	2008-11-17 14:03:54.000000000 -0800
+++ b/drivers/net/ixgb/ixgb_main.c	2008-11-17 14:03:57.000000000 -0800
@@ -321,6 +321,23 @@ ixgb_reset(struct ixgb_adapter *adapter)
 	}
 }
 
+static const struct net_device_ops ixgb_netdev_ops = {
+	.open 			= ixgb_open,
+	.stop			= ixgb_close,
+	.get_stats		= ixgb_get_stats,
+	.set_multicast_list	= ixgb_set_multi,
+	.validate_addr		= eth_validate_addr,
+	.set_mac_address	= ixgb_set_mac,
+	.change_mtu		= ixgb_change_mtu,
+	.tx_timeout		= ixgb_tx_timeout,
+	.vlan_rx_register	= ixgb_vlan_rx_register,
+	.vlan_rx_add_vid	= ixgb_vlan_rx_add_vid,
+	.vlan_rx_kill_vid	= ixgb_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= ixgb_netpoll,
+#endif
+};
+
 /**
  * ixgb_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -396,23 +413,11 @@ ixgb_probe(struct pci_dev *pdev, const s
 		}
 	}
 
-	netdev->open = &ixgb_open;
-	netdev->stop = &ixgb_close;
+	netdev->netdev_ops = &ixgb_netdev_ops;
 	netdev->hard_start_xmit = &ixgb_xmit_frame;
-	netdev->get_stats = &ixgb_get_stats;
-	netdev->set_multicast_list = &ixgb_set_multi;
-	netdev->set_mac_address = &ixgb_set_mac;
-	netdev->change_mtu = &ixgb_change_mtu;
 	ixgb_set_ethtool_ops(netdev);
-	netdev->tx_timeout = &ixgb_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 	netif_napi_add(netdev, &adapter->napi, ixgb_clean, 64);
-	netdev->vlan_rx_register = ixgb_vlan_rx_register;
-	netdev->vlan_rx_add_vid = ixgb_vlan_rx_add_vid;
-	netdev->vlan_rx_kill_vid = ixgb_vlan_rx_kill_vid;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = ixgb_netpoll;
-#endif
 
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
--- a/drivers/net/ixgbe/ixgbe_main.c	2008-11-17 14:03:54.000000000 -0800
+++ b/drivers/net/ixgbe/ixgbe_main.c	2008-11-17 14:05:29.000000000 -0800
@@ -3727,6 +3727,23 @@ static int ixgbe_link_config(struct ixgb
 	return hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
 }
 
+static const struct net_device_ops ixgbe_netdev_ops = {
+	.open 			= ixgbe_open,
+	.stop			= ixgbe_close,
+	.get_stats		= ixgbe_get_stats,
+	.set_multicast_list	= ixgbe_set_rx_mode,
+	.validate_addr		= eth_validate_addr,
+	.set_mac_address	= ixgbe_set_mac,
+	.change_mtu		= ixgbe_change_mtu,
+	.tx_timeout		= ixgbe_tx_timeout,
+	.vlan_rx_register	= ixgbe_vlan_rx_register,
+	.vlan_rx_add_vid	= ixgbe_vlan_rx_add_vid,
+	.vlan_rx_kill_vid	= ixgbe_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= ixgbe_netpoll,
+#endif
+};
+
 /**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -3808,23 +3825,10 @@ static int __devinit ixgbe_probe(struct 
 			continue;
 	}
 
-	netdev->open = &ixgbe_open;
-	netdev->stop = &ixgbe_close;
+	netdev->netdev_ops = &ixgbe_netdev_ops;
 	netdev->hard_start_xmit = &ixgbe_xmit_frame;
-	netdev->get_stats = &ixgbe_get_stats;
-	netdev->set_rx_mode = &ixgbe_set_rx_mode;
-	netdev->set_multicast_list = &ixgbe_set_rx_mode;
-	netdev->set_mac_address = &ixgbe_set_mac;
-	netdev->change_mtu = &ixgbe_change_mtu;
 	ixgbe_set_ethtool_ops(netdev);
-	netdev->tx_timeout = &ixgbe_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-	netdev->vlan_rx_register = ixgbe_vlan_rx_register;
-	netdev->vlan_rx_add_vid = ixgbe_vlan_rx_add_vid;
-	netdev->vlan_rx_kill_vid = ixgbe_vlan_rx_kill_vid;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = ixgbe_netpoll;
-#endif
 	strcpy(netdev->name, pci_name(pdev));
 
 	adapter->bd_number = cards_found;

-- 

