From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 01/15] net/mlx5: Modify RQ bitmask from mlx5 ifc
Date: Wed, 24 Aug 2016 13:39:00 +0300
Message-ID: <1472035154-14517-2-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Use mlx5 ifc MODIFY_BITMASK_VSD in mlx5e_modify_rq_vsd and expose counter
set capability bit in hca caps structure.

Signed-off-by: Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 ++-
 include/linux/mlx5/driver.h                       | 4 ----
 include/linux/mlx5/mlx5_ifc.h                     | 9 ++++++++-
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 10fa12a..9e36c15 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -489,7 +489,8 @@ static int mlx5e_modify_rq_vsd(struct mlx5e_rq *rq, bool vsd)
 	rqc = MLX5_ADDR_OF(modify_rq_in, in, ctx);
 
 	MLX5_SET(modify_rq_in, in, rq_state, MLX5_RQC_STATE_RDY);
-	MLX5_SET64(modify_rq_in, in, modify_bitmask, MLX5_RQ_BITMASK_VSD);
+	MLX5_SET64(modify_rq_in, in, modify_bitmask,
+		   MLX5_MODIFY_RQ_IN_MODIFY_BITMASK_VSD);
 	MLX5_SET(rqc, rqc, vsd, vsd);
 	MLX5_SET(rqc, rqc, state, MLX5_RQC_STATE_RDY);
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index ebe57ab..0ea78b5 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -49,10 +49,6 @@
 #include <linux/mlx5/srq.h>
 
 enum {
-	MLX5_RQ_BITMASK_VSD = 1 << 1,
-};
-
-enum {
 	MLX5_BOARD_ID_LEN = 64,
 	MLX5_MAX_NAME_LEN = 16,
 };
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 3766110..e1f8e34 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -779,7 +779,9 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         out_of_seq_cnt[0x1];
 	u8         vport_counters[0x1];
 	u8         retransmission_q_counters[0x1];
-	u8         reserved_at_183[0x3];
+	u8         reserved_at_183[0x1];
+	u8         modify_rq_counter_set_id[0x1];
+	u8         reserved_at_185[0x1];
 	u8         max_qp_cnt[0xa];
 	u8         pkey_table_size[0x10];
 
@@ -4750,6 +4752,11 @@ struct mlx5_ifc_modify_rq_out_bits {
 	u8         reserved_at_40[0x40];
 };
 
+enum {
+	MLX5_MODIFY_RQ_IN_MODIFY_BITMASK_VSD = 1ULL << 1,
+	MLX5_MODIFY_RQ_IN_MODIFY_BITMASK_MODIFY_RQ_COUNTER_SET_ID = 1ULL << 3,
+};
+
 struct mlx5_ifc_modify_rq_in_bits {
 	u8         opcode[0x10];
 	u8         reserved_at_10[0x10];
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
