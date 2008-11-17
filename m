From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 19/33] atl1e: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:26 -0800
Message-ID: <20081117234356.410646815@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55087 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240AbYKRAAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:11 -0500
Content-Disposition: inline; filename=atl1e-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/atl1e/atl1e_main.c	2008-11-17 11:59:32.000000000 -0800
+++ b/drivers/net/atl1e/atl1e_main.c	2008-11-17 12:05:05.000000000 -0800
@@ -2253,26 +2253,32 @@ static void atl1e_shutdown(struct pci_de
 	atl1e_suspend(pdev, PMSG_SUSPEND);
 }
 
+static const struct net_device_ops atl1e_netdev_ops = {
+	.open 	 	    = atl1e_open,
+	.stop 	 	    = atl1e_close,
+	.get_stats 	    = atl1e_get_stats,
+	.set_multicast_list = atl1e_set_multi,
+	.validate_addr	    = eth_validate_addr,
+	.set_mac_address    = atl1e_set_mac_addr,
+	.change_mtu 	    = atl1e_change_mtu,
+	.do_ioctl 	    = atl1e_ioctl,
+	.tx_timeout 	    = atl1e_tx_timeout,
+	.vlan_rx_register   = atl1e_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller    = atl1e_netpoll,
+#endif
+
+};
+
 static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 {
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	pci_set_drvdata(pdev, netdev);
 
 	netdev->irq  = pdev->irq;
-	netdev->open = &atl1e_open;
-	netdev->stop = &atl1e_close;
-	netdev->hard_start_xmit = &atl1e_xmit_frame;
-	netdev->get_stats = &atl1e_get_stats;
-	netdev->set_multicast_list = &atl1e_set_multi;
-	netdev->set_mac_address = &atl1e_set_mac_addr;
-	netdev->change_mtu = &atl1e_change_mtu;
-	netdev->do_ioctl = &atl1e_ioctl;
-	netdev->tx_timeout = &atl1e_tx_timeout;
+	netdev->netdev_ops = &atl1e_netdev_ops;
+	netdev->hard_start_xmit = atl1e_xmit_frame,
 	netdev->watchdog_timeo = AT_TX_WATCHDOG;
-	netdev->vlan_rx_register = atl1e_vlan_rx_register;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = atl1e_netpoll;
-#endif
 	atl1e_set_ethtool_ops(netdev);
 
 	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM |

-- 

