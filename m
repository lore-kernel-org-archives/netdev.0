From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 13/18] net/mlx4: Set enhanced QoS support by default when ETS supported
Date: Thu,  2 Apr 2015 16:31:18 +0300
Message-ID: <1427981483-19317-14-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45709 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750771AbbDBNcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:32:04 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

If HCA supports ETS QoS feature, set enhanced QoS bit in init_hca as default.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 16bbd6c..b93e23b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -49,9 +49,9 @@ enum {
 extern void __buggy_use_of_MLX4_GET(void);
 extern void __buggy_use_of_MLX4_PUT(void);
 
-static bool enable_qos;
+static bool enable_qos = true;
 module_param(enable_qos, bool, 0444);
-MODULE_PARM_DESC(enable_qos, "Enable Quality of Service support in the HCA (default: off)");
+MODULE_PARM_DESC(enable_qos, "Enable Enhanced QoS support (default: on)");
 
 #define MLX4_GET(dest, source, offset)				      \
 	do {							      \
@@ -1709,7 +1709,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 		*(inbox + INIT_HCA_FLAGS_OFFSET / 4) |= cpu_to_be32(1 << 3);
 
 	/* Enable QoS support if module parameter set */
-	if (enable_qos)
+	if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETS_CFG && enable_qos)
 		*(inbox + INIT_HCA_FLAGS_OFFSET / 4) |= cpu_to_be32(1 << 2);
 
 	/* enable counters */
-- 
1.7.1
