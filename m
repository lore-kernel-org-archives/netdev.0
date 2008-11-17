From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 25/33] igb: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:32 -0800
Message-ID: <20081117234356.919821405@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55106 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308AbYKRAAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:17 -0500
Content-Disposition: inline; filename=igb-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/igb/igb_main.c	2008-11-02 09:48:53.000000000 -0800
+++ b/drivers/net/igb/igb_main.c	2008-11-02 10:06:09.000000000 -0800
@@ -950,6 +950,24 @@ static int igb_is_need_ioport(struct pci
 	}
 }
 
+static const struct net_device_ops igb_netdev_ops = {
+	.open 		= igb_open,
+	.stop		= igb_close,
+	.get_stats	= igb_get_stats,
+	.set_multicast_list = igb_set_multi,
+	.set_mac_address = igb_set_mac,
+	.change_mtu	= igb_change_mtu,
+	.do_ioctl	= igb_ioctl,
+	.tx_timeout	= igb_tx_timeout,
+	.validate_addr	= eth_validate_addr,
+	.vlan_rx_register = igb_vlan_rx_register,
+	.vlan_rx_add_vid = igb_vlan_rx_add_vid,
+	.vlan_rx_kill_vid = igb_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = igb_netpoll,
+#endif
+};
+
 /**
  * igb_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -1060,22 +1078,9 @@ static int __devinit igb_probe(struct pc
 	if (!adapter->hw.hw_addr)
 		goto err_ioremap;
 
-	netdev->open = &igb_open;
-	netdev->stop = &igb_close;
-	netdev->get_stats = &igb_get_stats;
-	netdev->set_multicast_list = &igb_set_multi;
-	netdev->set_mac_address = &igb_set_mac;
-	netdev->change_mtu = &igb_change_mtu;
-	netdev->do_ioctl = &igb_ioctl;
+	netdev->netdev_ops = &igb_netdev_ops;
 	igb_set_ethtool_ops(netdev);
-	netdev->tx_timeout = &igb_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-	netdev->vlan_rx_register = igb_vlan_rx_register;
-	netdev->vlan_rx_add_vid = igb_vlan_rx_add_vid;
-	netdev->vlan_rx_kill_vid = igb_vlan_rx_kill_vid;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = igb_netpoll;
-#endif
 	netdev->hard_start_xmit = &igb_xmit_frame_adv;
 
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);

-- 

