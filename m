From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net V3 1/5] net/mlx4: Change ENOTSUPP to EOPNOTSUPP
Date: Thu, 23 Feb 2017 12:02:41 +0200
Message-ID: <1487844165-9934-2-git-send-email-tariqt@mellanox.com>
References: <1487844165-9934-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Dexuan Cui <decui@microsoft.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55590 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751098AbdBWKKS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 05:10:18 -0500
In-Reply-To: <1487844165-9934-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

As ENOTSUPP is specific to NFS, change the return error value to
EOPNOTSUPP in various places in the mlx4 driver.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Suggested-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c        | 2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c               | 2 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c             | 2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c             | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/mr.c               | 2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c               | 2 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 2 +-
 7 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index b04760a5034b..1dae8e40fb25 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -319,7 +319,7 @@ static int mlx4_en_ets_validate(struct mlx4_en_priv *priv, struct ieee_ets *ets)
 		default:
 			en_err(priv, "TC[%d]: Not supported TSA: %d\n",
 					i, ets->tc_tsa[i]);
-			return -ENOTSUPP;
+			return -EOPNOTSUPP;
 		}
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 3fe885ce1902..37e84a59e751 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -2436,7 +2436,7 @@ int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
 #define CONFIG_DEV_RX_CSUM_MODE_PORT2_BIT_OFFSET	4
 
 	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_CONFIG_DEV))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	err = mlx4_CONFIG_DEV_get(dev, &config_dev);
 	if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index 8258d08acd8c..e00f627331cb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -136,7 +136,7 @@ int mlx4_do_bond(struct mlx4_dev *dev, bool enable)
 	LIST_HEAD(bond_list);
 
 	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PORT_REMAP))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	ret = mlx4_disable_rx_port_check(dev, enable);
 	if (ret) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 15ef787e71ba..683234221741 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1447,7 +1447,7 @@ int mlx4_port_map_set(struct mlx4_dev *dev, struct mlx4_port_map *v2p)
 	int err;
 
 	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PORT_REMAP))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	mutex_lock(&priv->bond_mutex);
 
@@ -1884,7 +1884,7 @@ int mlx4_get_internal_clock_params(struct mlx4_dev *dev,
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	if (mlx4_is_slave(dev))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	if (!params)
 		return -EINVAL;
@@ -2384,7 +2384,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 	/* Query CONFIG_DEV parameters */
 	err = mlx4_config_dev_retrieval(dev, &params);
-	if (err && err != -ENOTSUPP) {
+	if (err && err != -EOPNOTSUPP) {
 		mlx4_err(dev, "Failed to query CONFIG_DEV parameters\n");
 	} else if (!err) {
 		dev->caps.rx_checksum_flags_port[1] = params.rx_csum_flags_port_1;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 395b5463cfd9..db65f72879e9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -823,7 +823,7 @@ int mlx4_mw_alloc(struct mlx4_dev *dev, u32 pd, enum mlx4_mw_type type,
 	     !(dev->caps.flags & MLX4_DEV_CAP_FLAG_MEM_WINDOW)) ||
 	     (type == MLX4_MW_TYPE_2 &&
 	     !(dev->caps.bmme_flags & MLX4_BMME_FLAG_TYPE_2_WIN)))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	index = mlx4_mpt_reserve(dev);
 	if (index == -1)
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index d1cd9c32a9ae..2d6abd4662b1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -447,7 +447,7 @@ int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
 		      & MLX4_DEV_CAP_FLAG2_UPDATE_QP_SRC_CHECK_LB)) {
 			mlx4_warn(dev,
 				  "Trying to set src check LB, but it isn't supported\n");
-			err = -ENOTSUPP;
+			err = -EOPNOTSUPP;
 			goto out;
 		}
 		pri_addr_path_mask |=
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 6fe9f76ae656..d8d5d161b8c7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4297,7 +4297,7 @@ int mlx4_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
 		  MLX4_DEV_CAP_FLAG2_UPDATE_QP_SRC_CHECK_LB)) {
 		mlx4_warn(dev, "Src check LB for slave %d isn't supported\n",
 			  slave);
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 
 	/* Just change the smac for the QP */
-- 
1.8.3.1
