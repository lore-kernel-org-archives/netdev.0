From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/22] mlx4: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:45 -0800
Message-ID: <20081121232239.488801095@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57021 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753977AbYKUXXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:19 -0500
Content-Disposition: inline; filename=mlx4-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/mlx4/en_netdev.c	2008-11-20 22:34:43.000000000 -0800
+++ b/drivers/net/mlx4/en_netdev.c	2008-11-20 22:36:59.000000000 -0800
@@ -953,6 +953,23 @@ static int mlx4_en_change_mtu(struct net
 	return 0;
 }
 
+static const struct net_device_ops mlx4_netdev_ops = {
+	.ndo_open		= mlx4_en_open,
+	.ndo_stop		= mlx4_en_close,
+	.ndo_start_xmit		= mlx4_en_xmit,
+	.ndo_get_stats		= mlx4_en_get_stats,
+	.ndo_set_multicast_list	= mlx4_en_set_multicast,
+	.ndo_set_mac_address	= mlx4_en_set_mac,
+	.ndo_change_mtu		= mlx4_en_change_mtu,
+	.ndo_tx_timeout		= mlx4_en_tx_timeout,
+	.ndo_vlan_rx_register	= mlx4_en_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= mlx4_en_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= mlx4_en_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= mlx4_en_netpoll,
+#endif
+};
+
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			struct mlx4_en_port_profile *prof)
 {
@@ -1029,22 +1046,9 @@ int mlx4_en_init_netdev(struct mlx4_en_d
 	/*
 	 * Initialize netdev entry points
 	 */
-
-	dev->open = &mlx4_en_open;
-	dev->stop = &mlx4_en_close;
-	dev->hard_start_xmit = &mlx4_en_xmit;
-	dev->get_stats = &mlx4_en_get_stats;
-	dev->set_multicast_list = &mlx4_en_set_multicast;
-	dev->set_mac_address = &mlx4_en_set_mac;
-	dev->change_mtu = &mlx4_en_change_mtu;
-	dev->tx_timeout = &mlx4_en_tx_timeout;
+	dev->netdev_ops = &mlx4_netdev_ops;
 	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
-	dev->vlan_rx_register = mlx4_en_vlan_rx_register;
-	dev->vlan_rx_add_vid = mlx4_en_vlan_rx_add_vid;
-	dev->vlan_rx_kill_vid = mlx4_en_vlan_rx_kill_vid;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = mlx4_en_netpoll;
-#endif
+
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
 	/* Set defualt MAC */

-- 

