From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/18] mlxsw: spectrum_buffers: Get max_buff defaults into limits exposed to user
Date: Thu, 14 Apr 2016 18:19:22 +0200
Message-ID: <1460650770-19382-11-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35824 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964829AbcDNQTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:54 -0400
Received: by mail-wm0-f42.google.com with SMTP id a140so154844735wma.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:53 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Although the device supports max_buff magic values 0 and 0xff, these are
not exposed to the user via devlink.
Therefore, adjust the default values to be within configurable range.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  4 ++++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 28 +++++++++++-----------
 2 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 57e4a63..fce5a96 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3566,6 +3566,10 @@ MLXSW_ITEM32(reg, sbcm, dir, 0x00, 0, 2);
  */
 MLXSW_ITEM32(reg, sbcm, min_buff, 0x18, 0, 24);
 
+/* shared max_buff limits for dynamic threshold for SBCM, SBPM */
+#define MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN 1
+#define MLXSW_REG_SBXX_DYN_MAX_BUFF_MAX 14
+
 /* reg_sbcm_max_buff
  * When the pool associated to the port-pg/tclass is configured to
  * static, Maximum buffer size for the limiter configured in cells.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 7ee2315..fd6b080 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -255,13 +255,13 @@ static int mlxsw_sp_sb_prs_init(struct mlxsw_sp *mlxsw_sp)
 
 static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_ingress[] = {
 	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(10000), 8, 0),
-	MLXSW_SP_SB_CM(0, 0, 0),
-	MLXSW_SP_SB_CM(0, 0, 0),
-	MLXSW_SP_SB_CM(0, 0, 0),
-	MLXSW_SP_SB_CM(0, 0, 0),
-	MLXSW_SP_SB_CM(0, 0, 0),
-	MLXSW_SP_SB_CM(0, 0, 0),
-	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
+	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
+	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
+	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
+	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
+	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
+	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
 	MLXSW_SP_SB_CM(0, 0, 0), /* dummy, this PG does not exist */
 	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(20000), 1, 3),
 };
@@ -385,19 +385,19 @@ static int mlxsw_sp_cpu_port_sb_cms_init(struct mlxsw_sp *mlxsw_sp)
 	}
 
 static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms_ingress[] = {
-	MLXSW_SP_SB_PM(0, 0xff),
-	MLXSW_SP_SB_PM(0, 0),
-	MLXSW_SP_SB_PM(0, 0),
-	MLXSW_SP_SB_PM(0, 0xff),
+	MLXSW_SP_SB_PM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MAX),
+	MLXSW_SP_SB_PM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN),
+	MLXSW_SP_SB_PM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN),
+	MLXSW_SP_SB_PM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MAX),
 };
 
 #define MLXSW_SP_SB_PMS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pms_ingress)
 
 static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms_egress[] = {
 	MLXSW_SP_SB_PM(0, 7),
-	MLXSW_SP_SB_PM(0, 0),
-	MLXSW_SP_SB_PM(0, 0),
-	MLXSW_SP_SB_PM(0, 0),
+	MLXSW_SP_SB_PM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN),
+	MLXSW_SP_SB_PM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN),
+	MLXSW_SP_SB_PM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN),
 };
 
 #define MLXSW_SP_SB_PMS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pms_egress)
-- 
2.5.5
