From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V3 1/5] net/mlx4_core: Add timestamping device capability
Date: Tue, 23 Apr 2013 19:06:47 +0300
Message-ID: <1366733211-10228-2-git-send-email-amirv@mellanox.com>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:44007 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932167Ab3DWQHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 12:07:00 -0400
In-Reply-To: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Add new device capability for timestamping support and query FW to retrieve it.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    7 ++++++-
 include/linux/mlx4/device.h             |    3 ++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index ab470d9..f1e7097 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -130,7 +130,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[1] = "RSS Toeplitz Hash Function support",
 		[2] = "RSS XOR Hash Function support",
 		[3] = "Device manage flow steering support",
-		[4] = "Automatic mac reassignment support"
+		[4] = "Automatic MAC reassignment support",
+		[5] = "Time stamping support"
 	};
 	int i;
 
@@ -444,6 +445,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_MSG_SZ_OFFSET		0x38
 #define QUERY_DEV_CAP_MAX_GID_OFFSET		0x3b
 #define QUERY_DEV_CAP_RATE_SUPPORT_OFFSET	0x3c
+#define QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET	0x3e
 #define QUERY_DEV_CAP_MAX_PKEY_OFFSET		0x3f
 #define QUERY_DEV_CAP_EXT_FLAGS_OFFSET		0x40
 #define QUERY_DEV_CAP_FLAGS_OFFSET		0x44
@@ -560,6 +562,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->fs_max_num_qp_per_entry = field;
 	MLX4_GET(stat_rate, outbox, QUERY_DEV_CAP_RATE_SUPPORT_OFFSET);
 	dev_cap->stat_rate_support = stat_rate;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
+	if (field & 0x80)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_TS;
 	MLX4_GET(ext_flags, outbox, QUERY_DEV_CAP_EXT_FLAGS_OFFSET);
 	MLX4_GET(flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	dev_cap->flags = flags | (u64)ext_flags << 32;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 1bc5a75..86ae260 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -152,7 +152,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_RSS_TOP		= 1LL <<  1,
 	MLX4_DEV_CAP_FLAG2_RSS_XOR		= 1LL <<  2,
 	MLX4_DEV_CAP_FLAG2_FS_EN		= 1LL <<  3,
-	MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN	= 1LL <<  4
+	MLX4_DEV_CAP_FLAGS2_REASSIGN_MAC_EN	= 1LL <<  4,
+	MLX4_DEV_CAP_FLAG2_TS			= 1LL <<  5
 };
 
 enum {
-- 
1.7.8.2
