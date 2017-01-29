From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 1/8] net/mlx5: Change ENOTSUPP to EOPNOTSUPP
Date: Sun, 29 Jan 2017 23:46:19 +0200
Message-ID: <20170129214626.21977-2-saeedm@mellanox.com>
References: <20170129214626.21977-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41592 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750775AbdA2Vqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 16:46:43 -0500
In-Reply-To: <20170129214626.21977-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

As ENOTSUPP is specific to NFS, change the return error value to
EOPNOTSUPP in various places in the mlx5 driver.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Suggested-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h               |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c         |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c       | 10 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c          |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c          |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c           |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c             |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c             |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/vport.c            |  2 +-
 12 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 3797cc7c1288..caa837e5e2b9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1728,7 +1728,7 @@ int mlx5_cmd_init(struct mlx5_core_dev *dev)
 	if (cmd->cmdif_rev > CMD_IF_REV) {
 		dev_err(&dev->pdev->dev, "driver does not support command interface version. driver %d, firmware %d\n",
 			CMD_IF_REV, cmd->cmdif_rev);
-		err = -ENOTSUPP;
+		err = -EOPNOTSUPP;
 		goto err_free_page;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 951dbd58594d..1619147a63e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -863,12 +863,12 @@ static inline void mlx5e_arfs_destroy_tables(struct mlx5e_priv *priv) {}
 
 static inline int mlx5e_arfs_enable(struct mlx5e_priv *priv)
 {
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 
 static inline int mlx5e_arfs_disable(struct mlx5e_priv *priv)
 {
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 #else
 int mlx5e_arfs_create_tables(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index f0b460f47f29..35f9ae037ba0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -89,7 +89,7 @@ static int mlx5e_dcbnl_ieee_getets(struct net_device *netdev,
 	int i;
 
 	if (!MLX5_CAP_GEN(priv->mdev, ets))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	ets->ets_cap = mlx5_max_tc(priv->mdev) + 1;
 	for (i = 0; i < ets->ets_cap; i++) {
@@ -236,7 +236,7 @@ static int mlx5e_dcbnl_ieee_setets(struct net_device *netdev,
 	int err;
 
 	if (!MLX5_CAP_GEN(priv->mdev, ets))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	err = mlx5e_dbcnl_validate_ets(netdev, ets);
 	if (err)
@@ -402,7 +402,7 @@ static u8 mlx5e_dcbnl_setall(struct net_device *netdev)
 	struct mlx5_core_dev *mdev = priv->mdev;
 	struct ieee_ets ets;
 	struct ieee_pfc pfc;
-	int err = -ENOTSUPP;
+	int err = -EOPNOTSUPP;
 	int i;
 
 	if (!MLX5_CAP_GEN(mdev, ets))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 5197817e4b2f..ffbdf9ee5a9b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -595,7 +595,7 @@ static int mlx5e_get_coalesce(struct net_device *netdev,
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
 	if (!MLX5_CAP_GEN(priv->mdev, cq_moderation))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	coal->rx_coalesce_usecs       = priv->params.rx_cq_moderation.usec;
 	coal->rx_max_coalesced_frames = priv->params.rx_cq_moderation.pkts;
@@ -620,7 +620,7 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 	int i;
 
 	if (!MLX5_CAP_GEN(mdev, cq_moderation))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	mutex_lock(&priv->state_lock);
 
@@ -1296,7 +1296,7 @@ static int mlx5e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	u32 mlx5_wol_mode;
 
 	if (!wol_supported)
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (wol->wolopts & ~wol_supported)
 		return -EINVAL;
@@ -1426,7 +1426,7 @@ static int set_pflag_rx_cqe_based_moder(struct net_device *netdev, bool enable)
 
 	if (rx_cq_period_mode == MLX5_CQ_PERIOD_MODE_START_FROM_CQE &&
 	    !MLX5_CAP_GEN(mdev, cq_period_start_from_cqe))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (!rx_mode_changed)
 		return 0;
@@ -1452,7 +1452,7 @@ static int set_pflag_rx_cqe_compress(struct net_device *netdev,
 	bool reset;
 
 	if (!MLX5_CAP_GEN(mdev, cqe_compression))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (enable && priv->tstamp.hwtstamp_config.rx_filter != HWTSTAMP_FILTER_NONE) {
 		netdev_err(netdev, "Can't enable cqe compression while timestamping is enabled.\n");
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index d088effd7160..f33f72d0237c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -92,7 +92,7 @@ static struct mlx5e_ethtool_table *get_flow_table(struct mlx5e_priv *priv,
 	ns = mlx5_get_flow_namespace(priv->mdev,
 				     MLX5_FLOW_NAMESPACE_ETHTOOL);
 	if (!ns)
-		return ERR_PTR(-ENOTSUPP);
+		return ERR_PTR(-EOPNOTSUPP);
 
 	table_size = min_t(u32, BIT(MLX5_CAP_FLOWTABLE(priv->mdev,
 						       flow_table_properties_nic_receive.log_max_ft_size)),
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2b7dd315020c..948351ae5bd2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3331,7 +3331,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
 	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	if (!MLX5_CAP_GEN(mdev, eth_net_offloads) ||
 	    !MLX5_CAP_GEN(mdev, nic_flow_table) ||
 	    !MLX5_CAP_ETH(mdev, csum_cap) ||
@@ -3343,7 +3343,7 @@ static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 			       < 3) {
 		mlx5_core_warn(mdev,
 			       "Not creating net device, some required device capabilities are missing\n");
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 	if (!MLX5_CAP_ETH(mdev, self_lb_en_modifiable))
 		mlx5_core_warn(mdev, "Self loop back prevention is not supported\n");
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index f14d9c9ba773..bb712139b36e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -133,7 +133,7 @@ static int modify_esw_vport_cvlan(struct mlx5_core_dev *dev, u32 vport,
 
 	if (!MLX5_CAP_ESW(dev, vport_cvlan_strip) ||
 	    !MLX5_CAP_ESW(dev, vport_cvlan_insert_if_not_exist))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	esw_debug(dev, "Set Vport[%d] VLAN %d qos %d set=%x\n",
 		  vport, vlan, qos, set_flags);
@@ -1630,7 +1630,7 @@ int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 	if (!MLX5_CAP_GEN(esw->dev, eswitch_flow_table) ||
 	    !MLX5_CAP_ESW_FLOWTABLE_FDB(esw->dev, ft_support)) {
 		esw_warn(esw->dev, "E-Switch FDB is not supported, aborting ...\n");
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 
 	if (!MLX5_CAP_ESW_INGRESS_ACL(esw->dev, ft_support))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 03293ed1cc22..657d319fc4c6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -166,7 +166,7 @@ static int esw_add_vlan_action_check(struct mlx5_esw_flow_attr *attr,
 	return 0;
 
 out_notsupp:
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 
 int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index c4478ecd8056..b53fc85a2375 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -322,7 +322,7 @@ int mlx5_cmd_update_fte(struct mlx5_core_dev *dev,
 						flow_table_properties_nic_receive.
 						flow_modify_en);
 	if (!atomic_mod_cap)
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	opmod = 1;
 
 	return	mlx5_cmd_set_fte(dev, opmod, modify_mask, ft, group_id, fte);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index d01e9f21d469..3c315eb8d270 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -807,7 +807,7 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 		return 0;
 	}
 
-	return -ENOTSUPP;
+	return -EOPNOTSUPP;
 }
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index d2ec9d232a70..fd12e0a377a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -620,7 +620,7 @@ static int mlx5_set_port_qetcr_reg(struct mlx5_core_dev *mdev, u32 *in,
 	u32 out[MLX5_ST_SZ_DW(qtct_reg)];
 
 	if (!MLX5_CAP_GEN(mdev, ets))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	return mlx5_core_access_reg(mdev, in, inlen, out, sizeof(out),
 				    MLX5_REG_QETCR, 0, 1);
@@ -632,7 +632,7 @@ static int mlx5_query_port_qetcr_reg(struct mlx5_core_dev *mdev, u32 *out,
 	u32 in[MLX5_ST_SZ_DW(qtct_reg)];
 
 	if (!MLX5_CAP_GEN(mdev, ets))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	memset(in, 0, sizeof(in));
 	return mlx5_core_access_reg(mdev, in, sizeof(in), out, outlen,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 269e4401c342..7129c30a2ab4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -532,7 +532,7 @@ int mlx5_modify_nic_vport_node_guid(struct mlx5_core_dev *mdev,
 	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
 		return -EACCES;
 	if (!MLX5_CAP_ESW(mdev, nic_vport_node_guid_modify))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	in = mlx5_vzalloc(inlen);
 	if (!in)
-- 
2.11.0
