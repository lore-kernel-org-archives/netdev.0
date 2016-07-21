From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/9] mlxsw: reg: Add Monitoring Port Analyzer Table register
Date: Thu, 21 Jul 2016 10:19:17 +0200
Message-ID: <1469089160-4239-7-git-send-email-jiri@resnulli.us>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34548 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbcGUITb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:19:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so1646056wma.1
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 01:19:30 -0700 (PDT)
In-Reply-To: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MPAT register is used to query and configure the Switch Port Analyzer
(SPAN) table. This register is used to configure a port as a mirror output
port, while after that a mirrored input port can be bound using MPAR
register.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 54 +++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 495e524..341ee245 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4618,6 +4618,58 @@ static inline void mlxsw_reg_mtmp_unpack(char *payload, unsigned int *p_temp,
 		mlxsw_reg_mtmp_sensor_name_memcpy_from(payload, sensor_name);
 }
 
+/* MPAT - Monitoring Port Analyzer Table
+ * -------------------------------------
+ * MPAT Register is used to query and configure the Switch PortAnalyzer Table.
+ * For an enabled analyzer, all fields except e (enable) cannot be modified.
+ */
+#define MLXSW_REG_MPAT_ID 0x901A
+#define MLXSW_REG_MPAT_LEN 0x78
+
+static const struct mlxsw_reg_info mlxsw_reg_mpat = {
+	.id = MLXSW_REG_MPAT_ID,
+	.len = MLXSW_REG_MPAT_LEN,
+};
+
+/* reg_mpat_pa_id
+ * Port Analyzer ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mpat, pa_id, 0x00, 28, 4);
+
+/* reg_mpat_system_port
+ * A unique port identifier for the final destination of the packet.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpat, system_port, 0x00, 0, 16);
+
+/* reg_mpat_e
+ * Enable. Indicating the Port Analyzer is enabled.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpat, e, 0x04, 31, 1);
+
+/* reg_mpat_qos
+ * Quality Of Service Mode.
+ * 0: CONFIGURED - QoS parameters (Switch Priority, and encapsulation
+ * PCP, DEI, DSCP or VL) are configured.
+ * 1: MAINTAIN - QoS parameters (Switch Priority, Color) are the
+ * same as in the original packet that has triggered the mirroring. For
+ * SPAN also the pcp,dei are maintained.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mpat, qos, 0x04, 26, 1);
+
+static inline void mlxsw_reg_mpat_pack(char *payload, u8 pa_id,
+				       u16 system_port, bool e)
+{
+	MLXSW_REG_ZERO(mpat, payload);
+	mlxsw_reg_mpat_pa_id_set(payload, pa_id);
+	mlxsw_reg_mpat_system_port_set(payload, system_port);
+	mlxsw_reg_mpat_e_set(payload, e);
+	mlxsw_reg_mpat_qos_set(payload, 1);
+}
+
 /* MLCR - Management LED Control Register
  * --------------------------------------
  * Controls the system LEDs.
@@ -5189,6 +5241,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "MFSM";
 	case MLXSW_REG_MTCAP_ID:
 		return "MTCAP";
+	case MLXSW_REG_MPAT_ID:
+		return "MPAT";
 	case MLXSW_REG_MTMP_ID:
 		return "MTMP";
 	case MLXSW_REG_MLCR_ID:
-- 
2.5.5
