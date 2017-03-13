From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 19/25] include/linux/mlx5: Add mlx5_wqe_eth_pad and enhanced-ipoib-qp-mode
Date: Mon, 13 Mar 2017 20:31:30 +0200
Message-ID: <1489429896-10781-20-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


mlx5_wqe_eth_pad will be used for TX flow for IB link type.
enhanced-ipoib-qp-mode for QP creation.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/qp.c | 4 ----
 include/linux/mlx5/qp.h         | 8 ++++++++
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 41e14d57fec9..d6918e6b6f28 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -71,10 +71,6 @@ enum {
 	[MLX5_IB_WR_UMR]			= MLX5_OPCODE_UMR,
 };
 
-struct mlx5_wqe_eth_pad {
-	u8 rsvd0[16];
-};
-
 enum raw_qp_set_mask_map {
 	MLX5_RAW_QP_MOD_SET_RQ_Q_CTR_ID		= 1UL << 0,
 	MLX5_RAW_QP_RATE_LIMIT			= 1UL << 1,
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 219c699c17b7..568fffff8ac9 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -221,6 +221,14 @@ enum {
 	MLX5_ETH_WQE_L4_CSUM            = 1 << 7,
 };
 
+struct mlx5_wqe_eth_pad {
+	u8 rsvd0[16];
+};
+
+enum {
+	MLX5_QP_ENHANCED_ULP_STATELESS_MODE = 2,
+};
+
 struct mlx5_wqe_eth_seg {
 	u8              rsvd0[4];
 	u8              cs_flags;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
