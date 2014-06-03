From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] IB/mlx4: fix GFP type in mlx4_table_get() and
 mlx4_qp_alloc_icm()
Date: Tue, 3 Jun 2014 22:08:02 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1406032205501.11302@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>
To: Roland Dreier <roland@purestorage.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 40f2287bd ("IB/mlx4: Implement IB_QP_CREATE_USE_GFP_NOIO") 
introduced passing of GFP flags when allocating memory resources for QPs.

GFP flags passed to mlx4_table_get() and mlx4_qp_alloc_icm() are always of 
gfp_t type, so let's not pass them as int. This fixes various sparse 
warnings.

Reported-by: fengguang.wu@intel.com
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---

Roland, please apply on top of your for-next branch to fix sparse warnings 
reported by Fengguang's bot. Thanks.

 drivers/net/ethernet/mellanox/mlx4/icm.c | 2 +-
 drivers/net/ethernet/mellanox/mlx4/icm.h | 2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c  | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index eb1747e..97c9b1d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -246,7 +246,7 @@ int mlx4_UNMAP_ICM_AUX(struct mlx4_dev *dev)
 }
 
 int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj,
-		   int gfp)
+		   gfp_t gfp)
 {
 	u32 i = (obj & (table->num_obj - 1)) /
 			(MLX4_TABLE_CHUNK_SIZE / table->obj_size);
diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.h b/drivers/net/ethernet/mellanox/mlx4/icm.h
index 067e6e0..0c73645 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.h
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.h
@@ -72,7 +72,7 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
 void mlx4_free_icm(struct mlx4_dev *dev, struct mlx4_icm *icm, int coherent);
 
 int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj,
-		   int gfp);
+		   gfp_t gfp);
 void mlx4_table_put(struct mlx4_dev *dev, struct mlx4_icm_table *table, u32 obj);
 int mlx4_table_get_range(struct mlx4_dev *dev, struct mlx4_icm_table *table,
 			 u32 start, u32 end);
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 917f0d0..07198ca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -316,7 +316,7 @@ err_out:
 	return err;
 }
 
-static int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn, int gfp)
+static int mlx4_qp_alloc_icm(struct mlx4_dev *dev, int qpn, gfp_t gfp)
 {
 	u64 param = 0;
 
-- 
1.9.2
