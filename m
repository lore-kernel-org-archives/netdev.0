From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: reg: Add high and low temperature thresholds
Date: Mon, 30 Oct 2017 10:51:18 +0100
Message-ID: <20171030095118.9098-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:52616 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932307AbdJ3JvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 05:51:20 -0400
Received: by mail-wr0-f196.google.com with SMTP id k62so11858576wrc.9
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 02:51:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The ASIC has the ability to generate events whenever a sensor indicates
the temperature goes above or below its high or low thresholds,
respectively.

In new firmware versions the firmware enforces a minimum of 5
degrees Celsius difference between both thresholds. Make the driver
conform to this requirement.

Note that this is required even when the events are disabled, as in
certain systems interrupts are generated via GPIO based on these
thresholds.

Fixes: 85926f877040 ("mlxsw: reg: Add definition of temperature management registers")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 4afc848..5acfbe5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5827,6 +5827,29 @@ MLXSW_ITEM32(reg, mtmp, mtr, 0x08, 30, 1);
  */
 MLXSW_ITEM32(reg, mtmp, max_temperature, 0x08, 0, 16);
 
+/* reg_mtmp_tee
+ * Temperature Event Enable.
+ * 0 - Do not generate event
+ * 1 - Generate event
+ * 2 - Generate single event
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mtmp, tee, 0x0C, 30, 2);
+
+#define MLXSW_REG_MTMP_THRESH_HI 0x348	/* 105 Celsius */
+
+/* reg_mtmp_temperature_threshold_hi
+ * High threshold for Temperature Warning Event. In 0.125 Celsius.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mtmp, temperature_threshold_hi, 0x0C, 0, 16);
+
+/* reg_mtmp_temperature_threshold_lo
+ * Low threshold for Temperature Warning Event. In 0.125 Celsius.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mtmp, temperature_threshold_lo, 0x10, 0, 16);
+
 #define MLXSW_REG_MTMP_SENSOR_NAME_SIZE 8
 
 /* reg_mtmp_sensor_name
@@ -5843,6 +5866,8 @@ static inline void mlxsw_reg_mtmp_pack(char *payload, u8 sensor_index,
 	mlxsw_reg_mtmp_sensor_index_set(payload, sensor_index);
 	mlxsw_reg_mtmp_mte_set(payload, max_temp_enable);
 	mlxsw_reg_mtmp_mtr_set(payload, max_temp_reset);
+	mlxsw_reg_mtmp_temperature_threshold_hi_set(payload,
+						    MLXSW_REG_MTMP_THRESH_HI);
 }
 
 static inline void mlxsw_reg_mtmp_unpack(char *payload, unsigned int *p_temp,
-- 
2.9.5
