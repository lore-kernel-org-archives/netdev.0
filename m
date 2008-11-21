From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/22] qlge: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:41 -0800
Message-ID: <20081121232239.149101042@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57008 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754556AbYKUXXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:15 -0500
Content-Disposition: inline; filename=qlge-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/qlge/qlge_main.c	2008-11-20 22:46:47.000000000 -0800
+++ b/drivers/net/qlge/qlge_main.c	2008-11-20 22:47:28.000000000 -0800
@@ -3715,6 +3715,22 @@ err_out:
 	return err;
 }
 
+
+static const struct net_device_ops qlge_netdev_ops = {
+	.ndo_open		= qlge_open,
+	.ndo_stop		= qlge_close,
+	.ndo_start_xmit		= qlge_send,
+	.ndo_change_mtu		= qlge_change_mtu,
+	.ndo_get_stats		= qlge_get_stats,
+	.ndo_set_multicast_list = qlge_set_multicast_list,
+	.ndo_set_mac_address	= qlge_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_tx_timeout		= qlge_tx_timeout,
+	.ndo_vlan_rx_register	= ql_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= ql_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= ql_vlan_rx_kill_vid,
+};
+
 static int __devinit qlge_probe(struct pci_dev *pdev,
 				const struct pci_device_id *pci_entry)
 {
@@ -3752,19 +3768,11 @@ static int __devinit qlge_probe(struct p
 	 */
 	ndev->tx_queue_len = qdev->tx_ring_size;
 	ndev->irq = pdev->irq;
-	ndev->open = qlge_open;
-	ndev->stop = qlge_close;
-	ndev->hard_start_xmit = qlge_send;
+
+	ndev->netdev_ops = &qlge_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &qlge_ethtool_ops);
-	ndev->change_mtu = qlge_change_mtu;
-	ndev->get_stats = qlge_get_stats;
-	ndev->set_multicast_list = qlge_set_multicast_list;
-	ndev->set_mac_address = qlge_set_mac_address;
-	ndev->tx_timeout = qlge_tx_timeout;
 	ndev->watchdog_timeo = 10 * HZ;
-	ndev->vlan_rx_register = ql_vlan_rx_register;
-	ndev->vlan_rx_add_vid = ql_vlan_rx_add_vid;
-	ndev->vlan_rx_kill_vid = ql_vlan_rx_kill_vid;
+
 	err = register_netdev(ndev);
 	if (err) {
 		dev_err(&pdev->dev, "net device registration failed.\n");

-- 

