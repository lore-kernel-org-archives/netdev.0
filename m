From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 1/8] net/mlx5e: Rearrange netdevice ops structures
Date: Mon,  7 Aug 2017 13:18:01 +0300
Message-ID: <20170807101808.22924-2-saeedm@mellanox.com>
References: <20170807101808.22924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53258 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752947AbdHGKSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 06:18:34 -0400
In-Reply-To: <20170807101808.22924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we are going to allow building the driver without eswitch support,
it would be possible to compile out the sriov netdevice ops struct such
that the basic ops instance will be used for non VF devices too.

Add missing udp tunnel ndos into mlx5e_netdev_ops_basic.

While here, rearrange some ndos in the sriov ops struct and put
vf/eswitch related ndos towards the end of it.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 57f31fa478ce..c2986777a1d8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3706,6 +3706,9 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
 	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
+	.ndo_udp_tunnel_add      = mlx5e_add_vxlan_port,
+	.ndo_udp_tunnel_del      = mlx5e_del_vxlan_port,
+	.ndo_features_check      = mlx5e_features_check,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
@@ -3730,13 +3733,19 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_features        = mlx5e_set_features,
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
+	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
 	.ndo_udp_tunnel_add	 = mlx5e_add_vxlan_port,
 	.ndo_udp_tunnel_del	 = mlx5e_del_vxlan_port,
-	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
 	.ndo_features_check      = mlx5e_features_check,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
+	.ndo_tx_timeout          = mlx5e_tx_timeout,
+	.ndo_xdp		 = mlx5e_xdp,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller     = mlx5e_netpoll,
+#endif
+	/* SRIOV E-Switch NDOs */
 	.ndo_set_vf_mac          = mlx5e_set_vf_mac,
 	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
 	.ndo_set_vf_spoofchk     = mlx5e_set_vf_spoofchk,
@@ -3745,11 +3754,6 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_get_vf_config       = mlx5e_get_vf_config,
 	.ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
 	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
-	.ndo_tx_timeout          = mlx5e_tx_timeout,
-	.ndo_xdp		 = mlx5e_xdp,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller     = mlx5e_netpoll,
-#endif
 	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
-- 
2.13.0
