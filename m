From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 04/13] net/mlx4_core: Add ethernet backplane autoneg device capability
Date: Mon, 27 Oct 2014 11:37:38 +0200
Message-ID: <1414402667-8841-5-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32863 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752264AbaJ0Jia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:30 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 7 ++++++-
 include/linux/mlx4/device.h             | 3 ++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 6fd9b85..72289ef 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -140,7 +140,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[11] = "MAD DEMUX (Secure-Host) support",
 		[12] = "Large cache line (>64B) CQE stride support",
 		[13] = "Large cache line (>64B) EQE stride support",
-		[14] = "Ethernet protocol control support"
+		[14] = "Ethernet protocol control support",
+		[15] = "Ethernet Backplane autoneg support"
 	};
 	int i;
 
@@ -575,6 +576,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_BMME_FLAGS_OFFSET		0x94
 #define QUERY_DEV_CAP_RSVD_LKEY_OFFSET		0x98
 #define QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET		0xa0
+#define QUERY_DEV_CAP_ETH_BACKPL_OFFSET		0x9c
 #define QUERY_DEV_CAP_FW_REASSIGN_MAC		0x9d
 #define QUERY_DEV_CAP_VXLAN			0x9e
 #define QUERY_DEV_CAP_MAD_DEMUX_OFFSET		0xb0
@@ -749,6 +751,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 	MLX4_GET(dev_cap->reserved_lkey, outbox,
 		 QUERY_DEV_CAP_RSVD_LKEY_OFFSET);
+	MLX4_GET(field32, outbox, QUERY_DEV_CAP_ETH_BACKPL_OFFSET);
+	if (field32 & (1 << 0))
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_FW_REASSIGN_MAC);
 	if (field & 1<<6)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_REASSIGN_MAC_EN;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 181cd9f..e4c136e 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -187,7 +187,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_MAD_DEMUX		= 1LL <<  11,
 	MLX4_DEV_CAP_FLAG2_CQE_STRIDE		= 1LL <<  12,
 	MLX4_DEV_CAP_FLAG2_EQE_STRIDE		= 1LL <<  13,
-	MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL        = 1LL <<  14
+	MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL        = 1LL <<  14,
+	MLX4_DEV_CAP_FLAG2_ETH_BACKPL_AN_REP	= 1LL <<  15
 };
 
 enum {
-- 
1.8.3.4
