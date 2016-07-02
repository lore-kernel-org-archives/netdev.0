From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] net/mlx4: Fix some indent inconsistancy
Date: Sat,  2 Jul 2016 14:31:05 +0200
Message-ID: <1467462665-10191-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: yishaih@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Silent a few smatch warnings about indentation.
This include the removal of a 'return' statement in 'resource_tracker.c'.
This 'return' will still be performed when breaking out of the
corresponding 'switch' block.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/mellanox/mlx4/intf.c          |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |  2 +-
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |  8 ++++----
 drivers/net/ethernet/mellanox/mlx4/mr.c            |  2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 22 ++++++++++------------
 5 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index dec77d6..7ae1cda 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -147,7 +147,7 @@ int mlx4_do_bond(struct mlx4_dev *dev, bool enable)
 	if (enable) {
 		dev->flags |= MLX4_FLAG_BONDED;
 	} else {
-		 ret = mlx4_virt2phy_port_map(dev, 1, 2);
+		ret = mlx4_virt2phy_port_map(dev, 1, 2);
 		if (ret) {
 			mlx4_err(dev, "Fail to reset port map\n");
 			return ret;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index b673a5f..75dd2e3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2600,7 +2600,7 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 	err = mlx4_init_uar_table(dev);
 	if (err) {
 		mlx4_err(dev, "Failed to initialize user access region table, aborting\n");
-		 return err;
+		return err;
 	}
 
 	err = mlx4_uar_alloc(dev, &priv->driver_uar);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index f2d0920..94b891c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -618,8 +618,8 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 				err = mlx4_READ_ENTRY(dev,
 						      entry->index,
 						      mailbox);
-					if (err)
-						goto out_mailbox;
+				if (err)
+					goto out_mailbox;
 				members_count =
 					be32_to_cpu(mgm->members_count) &
 					0xffffff;
@@ -657,8 +657,8 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 				err = mlx4_WRITE_ENTRY(dev,
 						       entry->index,
 						       mailbox);
-					if (err)
-						goto out_mailbox;
+				if (err)
+					goto out_mailbox;
 			}
 		}
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 9319519..395b546 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -248,7 +248,7 @@ static void mlx4_free_mtt_range(struct mlx4_dev *dev, u32 offset, int order)
 				  offset, order);
 		return;
 	}
-	 __mlx4_free_mtt_range(dev, offset, order);
+	__mlx4_free_mtt_range(dev, offset, order);
 }
 
 void mlx4_mtt_cleanup(struct mlx4_dev *dev, struct mlx4_mtt *mtt)
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index cd9b2b2..8b81114 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2372,16 +2372,15 @@ static int mpt_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		__mlx4_mpt_release(dev, index);
 		break;
 	case RES_OP_MAP_ICM:
-			index = get_param_l(&in_param);
-			id = index & mpt_mask(dev);
-			err = mr_res_start_move_to(dev, slave, id,
-						   RES_MPT_RESERVED, &mpt);
-			if (err)
-				return err;
-
-			__mlx4_mpt_free_icm(dev, mpt->key);
-			res_end_move(dev, slave, RES_MPT, id);
+		index = get_param_l(&in_param);
+		id = index & mpt_mask(dev);
+		err = mr_res_start_move_to(dev, slave, id,
+					   RES_MPT_RESERVED, &mpt);
+		if (err)
 			return err;
+
+		__mlx4_mpt_free_icm(dev, mpt->key);
+		res_end_move(dev, slave, RES_MPT, id);
 		break;
 	default:
 		err = -EINVAL;
@@ -4253,9 +4252,8 @@ int mlx4_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
 	     (1ULL << MLX4_UPD_QP_PATH_MASK_ETH_SRC_CHECK_MC_LB)) &&
 		!(dev->caps.flags2 &
 		  MLX4_DEV_CAP_FLAG2_UPDATE_QP_SRC_CHECK_LB)) {
-			mlx4_warn(dev,
-				  "Src check LB for slave %d isn't supported\n",
-				   slave);
+		mlx4_warn(dev, "Src check LB for slave %d isn't supported\n",
+			  slave);
 		return -ENOTSUPP;
 	}
 
-- 
2.7.4
