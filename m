From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/15] net/mlx5: Enhance MCAM reg to allow query on access reg support
Date: Fri, 23 Jun 2017 17:26:17 +0300
Message-ID: <20170623142622.16565-11-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54065 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754098AbdFWO1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:43 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Enhance MCAM to allow the driver to query which access regs are
supported. For now, expose the regs needed for FW flashing.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/device.h   |  3 +++
 include/linux/mlx5/mlx5_ifc.h | 13 +++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index b26a478930eb..556e1c31b5d0 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1094,6 +1094,9 @@ enum mlx5_mcam_feature_groups {
 #define MLX5_CAP_PCAM_FEATURE(mdev, fld) \
 	MLX5_GET(pcam_reg, (mdev)->caps.pcam, feature_cap_mask.enhanced_features.fld)
 
+#define MLX5_CAP_MCAM_REG(mdev, reg) \
+	MLX5_GET(mcam_reg, (mdev)->caps.mcam, mng_access_reg_cap_mask.access_regs.reg)
+
 #define MLX5_CAP_MCAM_FEATURE(mdev, fld) \
 	MLX5_GET(mcam_reg, (mdev)->caps.mcam, mng_feature_cap_mask.enhanced_features.fld)
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 28468ad804be..8f197b070cea 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -7745,6 +7745,18 @@ struct mlx5_ifc_mcam_enhanced_features_bits {
 	u8         pcie_performance_group[0x1];
 };
 
+struct mlx5_ifc_mcam_access_reg_bits {
+	u8         reserved_at_0[0x1c];
+	u8         mcda[0x1];
+	u8         mcc[0x1];
+	u8         mcqi[0x1];
+	u8         reserved_at_1f[0x1];
+
+	u8         regs_95_to_64[0x20];
+	u8         regs_63_to_32[0x20];
+	u8         regs_31_to_0[0x20];
+};
+
 struct mlx5_ifc_mcam_reg_bits {
 	u8         reserved_at_0[0x8];
 	u8         feature_group[0x8];
@@ -7754,6 +7766,7 @@ struct mlx5_ifc_mcam_reg_bits {
 	u8         reserved_at_20[0x20];
 
 	union {
+		struct mlx5_ifc_mcam_access_reg_bits access_regs;
 		u8         reserved_at_0[0x80];
 	} mng_access_reg_cap_mask;
 
-- 
2.11.0
