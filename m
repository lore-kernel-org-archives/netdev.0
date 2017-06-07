From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC net-next 1/4] net/mlx5e: Rearrange netdevice ops structures
Date: Thu,  8 Jun 2017 02:42:11 +0300
Message-ID: <20170607234214.24723-2-saeedm@mellanox.com>
References: <20170607234214.24723-1-saeedm@mellanox.com>
Cc: kernel-team@fb.com, Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: netdev@vger.kernel.org, Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35198 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751448AbdFGXuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:50:09 -0400
In-Reply-To: <20170607234214.24723-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we are going to allow compiling the driver without eswitch,
it means we will have to compile out mlx5e_netdev_ops_sriov and will
replace it with mlx5e_netdev_ops_basic.

Move missing vxlan ndos into mlx5e_netdev_ops_basic.

Rearrange some ndos in mlx5e_netdev_ops_sriov and put vf/eswitch related
ndos towards the end of the struct.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cdff04b2aea1..931347b797c4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3646,6 +3646,9 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
 	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
+	.ndo_udp_tunnel_add      = mlx5e_add_vxlan_port,
+	.ndo_udp_tunnel_del      = mlx5e_del_vxlan_port,
+	.ndo_features_check      = mlx5e_features_check,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
@@ -3670,13 +3673,19 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
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
@@ -3685,11 +3694,6 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
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
2.11.0
