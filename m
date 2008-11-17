From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 21/33] cxgb3: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:28 -0800
Message-ID: <20081117234356.581923873@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55093 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267AbYKRAAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:14 -0500
Content-Disposition: inline; filename=cxgb3-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/cxgb3/cxgb3_main.c	2008-11-17 13:56:57.000000000 -0800
+++ b/drivers/net/cxgb3/cxgb3_main.c	2008-11-17 13:58:49.000000000 -0800
@@ -2826,6 +2826,21 @@ static void __devinit print_port_info(st
 	}
 }
 
+static const struct net_device_ops cxgb_netdev_ops = {
+	.open = cxgb_open,
+	.stop = cxgb_close,
+	.get_stats = cxgb_get_stats,
+	.validate_addr	= eth_validate_addr,
+	.set_multicast_list = cxgb_set_rxmode,
+	.do_ioctl = cxgb_ioctl,
+	.change_mtu = cxgb_change_mtu,
+	.set_mac_address = cxgb_set_mac_addr,
+	.vlan_rx_register = vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = cxgb_netpoll,
+#endif
+};
+
 static int __devinit init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
@@ -2937,20 +2952,8 @@ static int __devinit init_one(struct pci
 			netdev->features |= NETIF_F_HIGHDMA;
 
 		netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-		netdev->vlan_rx_register = vlan_rx_register;
-
-		netdev->open = cxgb_open;
-		netdev->stop = cxgb_close;
+		netdev->netdev_ops = &cxgb_netdev_ops;
 		netdev->hard_start_xmit = t3_eth_xmit;
-		netdev->get_stats = cxgb_get_stats;
-		netdev->set_multicast_list = cxgb_set_rxmode;
-		netdev->do_ioctl = cxgb_ioctl;
-		netdev->change_mtu = cxgb_change_mtu;
-		netdev->set_mac_address = cxgb_set_mac_addr;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-		netdev->poll_controller = cxgb_netpoll;
-#endif
-
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
 

-- 

