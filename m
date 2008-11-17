From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 28/33] enic: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:35 -0800
Message-ID: <20081117234357.173505630@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55114 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343AbYKRAAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:20 -0500
Content-Disposition: inline; filename=enic-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/enic/enic_main.c	2008-11-17 13:23:10.000000000 -0800
+++ b/drivers/net/enic/enic_main.c	2008-11-17 13:26:25.000000000 -0800
@@ -1590,6 +1590,22 @@ static void enic_iounmap(struct enic *en
 		iounmap(enic->bar0.vaddr);
 }
 
+static const struct net_device_ops enic_netdev_ops = {
+	.open = enic_open,
+	.stop = enic_stop,
+	.get_stats = enic_get_stats,
+	.validate_addr = eth_validate_addr,
+	.set_multicast_list = enic_set_multicast_list,
+	.change_mtu = enic_change_mtu,
+	.vlan_rx_register = enic_vlan_rx_register,
+	.vlan_rx_add_vid = enic_vlan_rx_add_vid,
+	.vlan_rx_kill_vid = enic_vlan_rx_kill_vid,
+	.tx_timeout = enic_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = enic_poll_controller,
+#endif
+};
+
 static int __devinit enic_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
@@ -1813,21 +1829,10 @@ static int __devinit enic_probe(struct p
 		goto err_out_free_vnic_resources;
 	}
 
-	netdev->open = enic_open;
-	netdev->stop = enic_stop;
+	netdev->netdev_ops = &enic_netdev_ops;
 	netdev->hard_start_xmit = enic_hard_start_xmit;
-	netdev->get_stats = enic_get_stats;
-	netdev->set_multicast_list = enic_set_multicast_list;
-	netdev->change_mtu = enic_change_mtu;
-	netdev->vlan_rx_register = enic_vlan_rx_register;
-	netdev->vlan_rx_add_vid = enic_vlan_rx_add_vid;
-	netdev->vlan_rx_kill_vid = enic_vlan_rx_kill_vid;
-	netdev->tx_timeout = enic_tx_timeout;
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->ethtool_ops = &enic_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = enic_poll_controller;
-#endif
 
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	default:

-- 

