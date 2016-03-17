From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 06/13] mlxsw: reg: Share direction enum between SBPR, SBCM, SBPM
Date: Thu, 17 Mar 2016 18:13:46 +0100
Message-ID: <1458234833-25836-7-git-send-email-jiri@resnulli.us>
References: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34294 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031758AbcCQROG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:14:06 -0400
Received: by mail-wm0-f68.google.com with SMTP id p65so489422wmp.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:14:05 -0700 (PDT)
In-Reply-To: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Same field, same values, so share the same enum.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 23 +++++++---------------
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 20 +++++++++----------
 2 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index ffe4c03..fa1c7bd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2985,9 +2985,10 @@ static const struct mlxsw_reg_info mlxsw_reg_sbpr = {
 	.len = MLXSW_REG_SBPR_LEN,
 };
 
-enum mlxsw_reg_sbpr_dir {
-	MLXSW_REG_SBPR_DIR_INGRESS,
-	MLXSW_REG_SBPR_DIR_EGRESS,
+/* shared direstion enum for SBPR, SBCM, SBPM */
+enum mlxsw_reg_sbxx_dir {
+	MLXSW_REG_SBXX_DIR_INGRESS,
+	MLXSW_REG_SBXX_DIR_EGRESS,
 };
 
 /* reg_sbpr_dir
@@ -3020,7 +3021,7 @@ enum mlxsw_reg_sbpr_mode {
 MLXSW_ITEM32(reg, sbpr, mode, 0x08, 0, 4);
 
 static inline void mlxsw_reg_sbpr_pack(char *payload, u8 pool,
-				       enum mlxsw_reg_sbpr_dir dir,
+				       enum mlxsw_reg_sbxx_dir dir,
 				       enum mlxsw_reg_sbpr_mode mode, u32 size)
 {
 	MLXSW_REG_ZERO(sbpr, payload);
@@ -3062,11 +3063,6 @@ MLXSW_ITEM32(reg, sbcm, local_port, 0x00, 16, 8);
  */
 MLXSW_ITEM32(reg, sbcm, pg_buff, 0x00, 8, 6);
 
-enum mlxsw_reg_sbcm_dir {
-	MLXSW_REG_SBCM_DIR_INGRESS,
-	MLXSW_REG_SBCM_DIR_EGRESS,
-};
-
 /* reg_sbcm_dir
  * Direction.
  * Access: Index
@@ -3099,7 +3095,7 @@ MLXSW_ITEM32(reg, sbcm, max_buff, 0x1C, 0, 24);
 MLXSW_ITEM32(reg, sbcm, pool, 0x24, 0, 4);
 
 static inline void mlxsw_reg_sbcm_pack(char *payload, u8 local_port, u8 pg_buff,
-				       enum mlxsw_reg_sbcm_dir dir,
+				       enum mlxsw_reg_sbxx_dir dir,
 				       u32 min_buff, u32 max_buff, u8 pool)
 {
 	MLXSW_REG_ZERO(sbcm, payload);
@@ -3139,11 +3135,6 @@ MLXSW_ITEM32(reg, sbpm, local_port, 0x00, 16, 8);
  */
 MLXSW_ITEM32(reg, sbpm, pool, 0x00, 8, 4);
 
-enum mlxsw_reg_sbpm_dir {
-	MLXSW_REG_SBPM_DIR_INGRESS,
-	MLXSW_REG_SBPM_DIR_EGRESS,
-};
-
 /* reg_sbpm_dir
  * Direction.
  * Access: Index
@@ -3170,7 +3161,7 @@ MLXSW_ITEM32(reg, sbpm, min_buff, 0x18, 0, 24);
 MLXSW_ITEM32(reg, sbpm, max_buff, 0x1C, 0, 24);
 
 static inline void mlxsw_reg_sbpm_pack(char *payload, u8 local_port, u8 pool,
-				       enum mlxsw_reg_sbpm_dir dir,
+				       enum mlxsw_reg_sbxx_dir dir,
 				       u32 min_buff, u32 max_buff)
 {
 	MLXSW_REG_ZERO(sbpm, payload);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index d59195e..fb5f787 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -86,7 +86,7 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 
 struct mlxsw_sp_sb_pool {
 	u8 pool;
-	enum mlxsw_reg_sbpr_dir dir;
+	enum mlxsw_reg_sbxx_dir dir;
 	enum mlxsw_reg_sbpr_mode mode;
 	u32 size;
 };
@@ -107,11 +107,11 @@ struct mlxsw_sp_sb_pool {
 	}
 
 #define MLXSW_SP_SB_POOL_INGRESS(_pool, _size)			\
-	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBPR_DIR_INGRESS,	\
+	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBXX_DIR_INGRESS,	\
 			 MLXSW_REG_SBPR_MODE_DYNAMIC, _size)
 
 #define MLXSW_SP_SB_POOL_EGRESS(_pool, _size)			\
-	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBPR_DIR_EGRESS,	\
+	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBXX_DIR_EGRESS,	\
 			 MLXSW_REG_SBPR_MODE_DYNAMIC, _size)
 
 static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools[] = {
@@ -151,7 +151,7 @@ struct mlxsw_sp_sb_cm {
 		u8 pg;
 		u8 tc;
 	} u;
-	enum mlxsw_reg_sbcm_dir dir;
+	enum mlxsw_reg_sbxx_dir dir;
 	u32 min_buff;
 	u32 max_buff;
 	u8 pool;
@@ -167,15 +167,15 @@ struct mlxsw_sp_sb_cm {
 	}
 
 #define MLXSW_SP_SB_CM_INGRESS(_pg, _min_buff, _max_buff)		\
-	MLXSW_SP_SB_CM(_pg, MLXSW_REG_SBCM_DIR_INGRESS,			\
+	MLXSW_SP_SB_CM(_pg, MLXSW_REG_SBXX_DIR_INGRESS,			\
 		       _min_buff, _max_buff, 0)
 
 #define MLXSW_SP_SB_CM_EGRESS(_tc, _min_buff, _max_buff)		\
-	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBCM_DIR_EGRESS,			\
+	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBXX_DIR_EGRESS,			\
 		       _min_buff, _max_buff, 0)
 
 #define MLXSW_SP_CPU_PORT_SB_CM_EGRESS(_tc)				\
-	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBCM_DIR_EGRESS, 104, 2, 3)
+	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBXX_DIR_EGRESS, 104, 2, 3)
 
 static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms[] = {
 	MLXSW_SP_SB_CM_INGRESS(0, 10000 / MLXSW_SP_SB_BYTES_PER_CELL, 8),
@@ -282,7 +282,7 @@ static int mlxsw_sp_cpu_port_sb_cms_init(struct mlxsw_sp *mlxsw_sp)
 
 struct mlxsw_sp_sb_pm {
 	u8 pool;
-	enum mlxsw_reg_sbpm_dir dir;
+	enum mlxsw_reg_sbxx_dir dir;
 	u32 min_buff;
 	u32 max_buff;
 };
@@ -296,11 +296,11 @@ struct mlxsw_sp_sb_pm {
 	}
 
 #define MLXSW_SP_SB_PM_INGRESS(_pool, _min_buff, _max_buff)	\
-	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBPM_DIR_INGRESS,	\
+	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBXX_DIR_INGRESS,	\
 		       _min_buff, _max_buff)
 
 #define MLXSW_SP_SB_PM_EGRESS(_pool, _min_buff, _max_buff)	\
-	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBPM_DIR_EGRESS,	\
+	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBXX_DIR_EGRESS,	\
 		       _min_buff, _max_buff)
 
 static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms[] = {
-- 
2.5.0
