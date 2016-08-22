From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 16/17] net/mlx5: Modify RQ bitmask from mlx5 ifc
Date: Mon, 22 Aug 2016 19:51:13 +0300
Message-ID: <1471884674-22709-17-git-send-email-saeedm@mellanox.com>
References: <1471884674-22709-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60351 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755250AbcHVQvl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 12:51:41 -0400
In-Reply-To: <1471884674-22709-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

Use mlx5 ifc MODIFY_BITMASK_VSD in mlx5e_modify_rq_vsd and expose counter
set capability bit in hca caps structure.

Signed-off-by: Alex Vesker <valex@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
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
