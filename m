From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Fix kernel Oops (mem corruption) when working with more than 80 VFs
Date: Mon,  2 Feb 2015 15:18:42 +0200
Message-ID: <1422883122-29020-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40055 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753790AbbBBNSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 08:18:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Commit de966c592802 (net/mlx4_core: Support more than 64 VFs) was meant to
allow up to 126 VFs.  However, due to leaving MLX4_MFUNC_MAX too low, using
more than 80 VFs resulted in memory corruptions (and Oopses) when more than
80 VFs were requested. In addition, the number of slaves was left too high.

This commit fixes these issues.

Fixes: de966c592802 ("net/mlx4_core: Support more than 64 VFs")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h | 3 ++-
 include/linux/mlx4/device.h               | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index bdd4eea..210691c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -235,7 +235,8 @@ do {									\
 extern int mlx4_log_num_mgm_entry_size;
 extern int log_mtts_per_seg;
 
-#define MLX4_MAX_NUM_SLAVES	(MLX4_MAX_NUM_PF + MLX4_MAX_NUM_VF)
+#define MLX4_MAX_NUM_SLAVES	(min(MLX4_MAX_NUM_PF + MLX4_MAX_NUM_VF, \
+				     MLX4_MFUNC_MAX))
 #define ALL_SLAVES 0xff
 
 struct mlx4_bitmap {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 25c791e..5f3a9aa 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -97,7 +97,7 @@ enum {
 	MLX4_MAX_NUM_PF		= 16,
 	MLX4_MAX_NUM_VF		= 126,
 	MLX4_MAX_NUM_VF_P_PORT  = 64,
-	MLX4_MFUNC_MAX		= 80,
+	MLX4_MFUNC_MAX		= 128,
 	MLX4_MAX_EQ_NUM		= 1024,
 	MLX4_MFUNC_EQ_NUM	= 4,
 	MLX4_MFUNC_MAX_EQES     = 8,
-- 
1.9.3
