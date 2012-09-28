From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH 1/3] net/mlx4_core: Add timestamping device capability
Date: Fri, 28 Sep 2012 12:03:21 +0200
Message-ID: <1348826603-17439-2-git-send-email-yevgenyp@mellanox.com>
References: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:33217 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757044Ab2I1KDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 06:03:32 -0400
In-Reply-To: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Add new device capability for timestamping support and query FW to retrieve it.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    7 ++++++-
 include/linux/mlx4/device.h             |    3 ++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index c696484..d7b0850 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -125,7 +125,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[0] = "RSS support",
 		[1] = "RSS Toeplitz Hash Function support",
 		[2] = "RSS XOR Hash Function support",
-		[3] = "Device manage flow steering support"
+		[3] = "Device manage flow steering support",
+		[4] = "Time stamping support"
 	};
 	int i;
 
@@ -402,6 +403,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_MSG_SZ_OFFSET		0x38
 #define QUERY_DEV_CAP_MAX_GID_OFFSET		0x3b
 #define QUERY_DEV_CAP_RATE_SUPPORT_OFFSET	0x3c
+#define QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET	0x3e
 #define QUERY_DEV_CAP_MAX_PKEY_OFFSET		0x3f
 #define QUERY_DEV_CAP_EXT_FLAGS_OFFSET		0x40
 #define QUERY_DEV_CAP_FLAGS_OFFSET		0x44
@@ -517,6 +519,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->fs_max_num_qp_per_entry = field;
 	MLX4_GET(stat_rate, outbox, QUERY_DEV_CAP_RATE_SUPPORT_OFFSET);
 	dev_cap->stat_rate_support = stat_rate;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
+	if (field & 0x80)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_TS_EN;
 	MLX4_GET(ext_flags, outbox, QUERY_DEV_CAP_EXT_FLAGS_OFFSET);
 	MLX4_GET(flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	dev_cap->flags = flags | (u64)ext_flags << 32;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 6e1b0f9..e482e6b 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -142,7 +142,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_RSS			= 1LL <<  0,
 	MLX4_DEV_CAP_FLAG2_RSS_TOP		= 1LL <<  1,
 	MLX4_DEV_CAP_FLAG2_RSS_XOR		= 1LL <<  2,
-	MLX4_DEV_CAP_FLAG2_FS_EN		= 1LL <<  3
+	MLX4_DEV_CAP_FLAG2_FS_EN		= 1LL <<  3,
+	MLX4_DEV_CAP_FLAG2_TS_EN		= 1LL <<  4
 };
 
 #define MLX4_ATTR_EXTENDED_PORT_INFO	cpu_to_be16(0xff90)
-- 
1.7.8.2
