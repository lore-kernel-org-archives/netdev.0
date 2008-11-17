From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 20/33] atlx: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:27 -0800
Message-ID: <20081117234356.493836247@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55090 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbYKRAAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:12 -0500
Content-Disposition: inline; filename=atlx-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/atlx/atl1.c	2008-11-17 13:02:49.000000000 -0800
+++ b/drivers/net/atlx/atl1.c	2008-11-17 13:04:16.000000000 -0800
@@ -2880,6 +2880,21 @@ static void atl1_poll_controller(struct 
 }
 #endif
 
+static const struct net_device_ops atl1_netdev_ops = {
+	.open		    = atl1_open,
+	.stop		    = atl1_close,
+	.set_multicast_list = atlx_set_multi,
+	.validate_addr	    = eth_validate_addr,
+	.set_mac_address    = atl1_set_mac,
+	.change_mtu	    = atl1_change_mtu,
+	.do_ioctl	    = atlx_ioctl,
+	.tx_timeout	    = atlx_tx_timeout,
+	.vlan_rx_register   = atlx_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller    = atl1_poll_controller,
+#endif
+};
+
 /*
  * atl1_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -2967,20 +2982,9 @@ static int __devinit atl1_probe(struct p
 	adapter->mii.phy_id_mask = 0x1f;
 	adapter->mii.reg_num_mask = 0x1f;
 
-	netdev->open = &atl1_open;
-	netdev->stop = &atl1_close;
+	netdev->netdev_ops = &atl1_netdev_ops;
 	netdev->hard_start_xmit = &atl1_xmit_frame;
-
-	netdev->set_multicast_list = &atlx_set_multi;
-	netdev->set_mac_address = &atl1_set_mac;
-	netdev->change_mtu = &atl1_change_mtu;
-	netdev->do_ioctl = &atlx_ioctl;
-	netdev->tx_timeout = &atlx_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = atl1_poll_controller;
-#endif
-	netdev->vlan_rx_register = atlx_vlan_rx_register;
 
 	netdev->ethtool_ops = &atl1_ethtool_ops;
 	adapter->bd_number = cards_found;
--- a/drivers/net/atlx/atl2.c	2008-11-17 13:02:49.000000000 -0800
+++ b/drivers/net/atlx/atl2.c	2008-11-17 14:48:20.000000000 -0800
@@ -1311,6 +1311,22 @@ static void atl2_poll_controller(struct 
 }
 #endif
 
+
+static const struct net_device_ops atl2_netdev_ops = {
+	.open		    = atl2_open,
+	.stop		    = atl2_close,
+	.set_multicast_list = atl2_set_multi,
+	.validate_addr	    = eth_validate_addr,
+	.set_mac_address    = atl2_set_mac,
+	.change_mtu	    = atl2_change_mtu,
+	.do_ioctl	    = atl2_ioctl,
+	.tx_timeout	    = atl2_tx_timeout,
+	.vlan_rx_register   = atl2_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller    = atl2_poll_controller,
+#endif
+};
+
 /*
  * atl2_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -1384,25 +1400,10 @@ static int __devinit atl2_probe(struct p
 
 	atl2_setup_pcicmd(pdev);
 
-	netdev->open = &atl2_open;
-	netdev->stop = &atl2_close;
 	netdev->hard_start_xmit = &atl2_xmit_frame;
-	netdev->set_multicast_list = &atl2_set_multi;
-	netdev->set_mac_address = &atl2_set_mac;
-	netdev->change_mtu = &atl2_change_mtu;
-	netdev->do_ioctl = &atl2_ioctl;
+	netdev->netdev_ops = &atl2_netdev_ops;
 	atl2_set_ethtool_ops(netdev);
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = atl2_poll_controller;
-#endif
-#ifdef HAVE_TX_TIMEOUT
-	netdev->tx_timeout = &atl2_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-#endif
-#ifdef NETIF_F_HW_VLAN_TX
-	netdev->vlan_rx_register = atl2_vlan_rx_register;
-#endif
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	netdev->mem_start = mmio_start;

-- 

