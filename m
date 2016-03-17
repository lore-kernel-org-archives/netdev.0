From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 11/13] mlxsw: spectrum_buffers: Rename "pool" to "pr" in initialization
Date: Thu, 17 Mar 2016 18:13:51 +0100
Message-ID: <1458234833-25836-12-git-send-email-jiri@resnulli.us>
References: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35830 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031764AbcCQROK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:14:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id l124so441012wmf.2
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:14:10 -0700 (PDT)
In-Reply-To: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be consintent with rest of the registers (pm, cm) and use "pr" here.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 70 +++++++++++-----------
 1 file changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 820a19c0..41212c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -100,78 +100,78 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 
 #define MLXSW_SP_SB_BYTES_PER_CELL 96
 
-struct mlxsw_sp_sb_pool {
+struct mlxsw_sp_sb_pr {
 	enum mlxsw_reg_sbpr_mode mode;
 	u32 size;
 };
 
-#define MLXSW_SP_SB_POOL_INGRESS_SIZE				\
+#define MLXSW_SP_SB_PR_INGRESS_SIZE				\
 	((15000000 - (2 * 20000 * MLXSW_PORT_MAX_PORTS)) /	\
 	 MLXSW_SP_SB_BYTES_PER_CELL)
-#define MLXSW_SP_SB_POOL_EGRESS_SIZE				\
+#define MLXSW_SP_SB_PR_EGRESS_SIZE				\
 	((14000000 - (8 * 1500 * MLXSW_PORT_MAX_PORTS)) /	\
 	 MLXSW_SP_SB_BYTES_PER_CELL)
 
-#define MLXSW_SP_SB_POOL(_mode, _size)	\
+#define MLXSW_SP_SB_PR(_mode, _size)	\
 	{				\
 		.mode = _mode,		\
 		.size = _size,		\
 	}
 
-static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools_ingress[] = {
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC,
-			 MLXSW_SP_SB_POOL_INGRESS_SIZE),
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+static const struct mlxsw_sp_sb_pr mlxsw_sp_sb_prs_ingress[] = {
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
+		       MLXSW_SP_SB_PR_INGRESS_SIZE),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 };
 
-#define MLXSW_SP_SB_POOLS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pools_ingress)
+#define MLXSW_SP_SB_PRS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_prs_ingress)
 
-static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools_egress[] = {
+static const struct mlxsw_sp_sb_pr mlxsw_sp_sb_prs_egress[] = {
 
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC,
-			 MLXSW_SP_SB_POOL_EGRESS_SIZE),
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
-	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC,
-			 MLXSW_SP_SB_POOL_EGRESS_SIZE),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
+		       MLXSW_SP_SB_PR_EGRESS_SIZE),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
+		       MLXSW_SP_SB_PR_EGRESS_SIZE),
 };
 
-#define MLXSW_SP_SB_POOLS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pools_egress)
+#define MLXSW_SP_SB_PRS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_prs_egress)
 
-static int __mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp,
-				    enum mlxsw_reg_sbxx_dir dir,
-				    const struct mlxsw_sp_sb_pool *pools,
-				    size_t pools_len)
+static int __mlxsw_sp_sb_prs_init(struct mlxsw_sp *mlxsw_sp,
+				  enum mlxsw_reg_sbxx_dir dir,
+				  const struct mlxsw_sp_sb_pr *prs,
+				  size_t prs_len)
 {
 	int i;
 	int err;
 
-	for (i = 0; i < pools_len; i++) {
-		const struct mlxsw_sp_sb_pool *pool;
+	for (i = 0; i < prs_len; i++) {
+		const struct mlxsw_sp_sb_pr *pr;
 
-		pool = &pools[i];
+		pr = &prs[i];
 		err = mlxsw_sp_sb_pr_write(mlxsw_sp, i, dir,
-					   pool->mode, pool->size);
+					   pr->mode, pr->size);
 		if (err)
 			return err;
 	}
 	return 0;
 }
 
-static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
+static int mlxsw_sp_sb_prs_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
-	err = __mlxsw_sp_sb_pools_init(mlxsw_sp, MLXSW_REG_SBXX_DIR_INGRESS,
-				       mlxsw_sp_sb_pools_ingress,
-				       MLXSW_SP_SB_POOLS_INGRESS_LEN);
+	err = __mlxsw_sp_sb_prs_init(mlxsw_sp, MLXSW_REG_SBXX_DIR_INGRESS,
+				     mlxsw_sp_sb_prs_ingress,
+				     MLXSW_SP_SB_PRS_INGRESS_LEN);
 	if (err)
 		return err;
-	return __mlxsw_sp_sb_pools_init(mlxsw_sp, MLXSW_REG_SBXX_DIR_EGRESS,
-					mlxsw_sp_sb_pools_egress,
-					MLXSW_SP_SB_POOLS_EGRESS_LEN);
+	return __mlxsw_sp_sb_prs_init(mlxsw_sp, MLXSW_REG_SBXX_DIR_EGRESS,
+					mlxsw_sp_sb_prs_egress,
+					MLXSW_SP_SB_PRS_EGRESS_LEN);
 }
 
 struct mlxsw_sp_sb_cm {
@@ -435,7 +435,7 @@ int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
-	err = mlxsw_sp_sb_pools_init(mlxsw_sp);
+	err = mlxsw_sp_sb_prs_init(mlxsw_sp);
 	if (err)
 		return err;
 	err = mlxsw_sp_cpu_port_sb_cms_init(mlxsw_sp);
-- 
2.5.0
