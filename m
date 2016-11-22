From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: reg: Add Management Fan Speed Limit register
Date: Tue, 22 Nov 2016 11:24:12 +0100
Message-ID: <1479810253-9114-2-git-send-email-jiri@resnulli.us>
References: <1479810253-9114-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, cera@cera.cz, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:34192 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755489AbcKVKYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 05:24:17 -0500
Received: by mail-wj0-f195.google.com with SMTP id xy5so5925668wjc.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 02:24:16 -0800 (PST)
In-Reply-To: <1479810253-9114-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The MFSL register is used to configure the fan speed event / interrupt
notification mechanism. Fan speed threshold are defined for both
under-speed and over-speed.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 49 +++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index edad7cb..2618e9c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4518,6 +4518,54 @@ static inline void mlxsw_reg_mfsm_pack(char *payload, u8 tacho)
 	mlxsw_reg_mfsm_tacho_set(payload, tacho);
 }
 
+/* MFSL - Management Fan Speed Limit Register
+ * ------------------------------------------
+ * The Fan Speed Limit register is used to configure the fan speed
+ * event / interrupt notification mechanism. Fan speed threshold are
+ * defined for both under-speed and over-speed.
+ */
+#define MLXSW_REG_MFSL_ID 0x9004
+#define MLXSW_REG_MFSL_LEN 0x0C
+
+MLXSW_REG_DEFINE(mfsl, MLXSW_REG_MFSL_ID, MLXSW_REG_MFSL_LEN);
+
+/* reg_mfsl_tacho
+ * Fan tachometer index.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mfsl, tacho, 0x00, 24, 4);
+
+/* reg_mfsl_tach_min
+ * Tachometer minimum value (minimum RPM).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mfsl, tach_min, 0x04, 0, 16);
+
+/* reg_mfsl_tach_max
+ * Tachometer maximum value (maximum RPM).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mfsl, tach_max, 0x08, 0, 16);
+
+static inline void mlxsw_reg_mfsl_pack(char *payload, u8 tacho,
+				       u16 tach_min, u16 tach_max)
+{
+	MLXSW_REG_ZERO(mfsl, payload);
+	mlxsw_reg_mfsl_tacho_set(payload, tacho);
+	mlxsw_reg_mfsl_tach_min_set(payload, tach_min);
+	mlxsw_reg_mfsl_tach_max_set(payload, tach_max);
+}
+
+static inline void mlxsw_reg_mfsl_unpack(char *payload, u8 tacho,
+					 u16 *p_tach_min, u16 *p_tach_max)
+{
+	if (p_tach_min)
+		*p_tach_min = mlxsw_reg_mfsl_tach_min_get(payload);
+
+	if (p_tach_max)
+		*p_tach_max = mlxsw_reg_mfsl_tach_max_get(payload);
+}
+
 /* MTCAP - Management Temperature Capabilities
  * -------------------------------------------
  * This register exposes the capabilities of the device and
@@ -5228,6 +5276,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mfcr),
 	MLXSW_REG(mfsc),
 	MLXSW_REG(mfsm),
+	MLXSW_REG(mfsl),
 	MLXSW_REG(mtcap),
 	MLXSW_REG(mtmp),
 	MLXSW_REG(mpat),
-- 
2.7.4
