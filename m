From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] mlxsw: reg: Add definition of fan management registers
Date: Thu, 26 Nov 2015 12:03:32 +0100
Message-ID: <1448535813-14882-6-git-send-email-jiri@resnulli.us>
References: <1448535813-14882-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36720 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbKZLDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 06:03:42 -0500
Received: by wmww144 with SMTP id w144so16716466wmw.1
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 03:03:41 -0800 (PST)
In-Reply-To: <1448535813-14882-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add definition of MFCR, MFSC and MFSM which provide possibility to
control and monitor fans.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 133 ++++++++++++++++++++++++++++++
 1 file changed, 133 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 459e0490..f894193 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2087,6 +2087,133 @@ static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 	mlxsw_reg_hpkt_ctrl_set(payload, MLXSW_REG_HPKT_CTRL_PACKET_DEFAULT);
 }
 
+/* MFCR - Management Fan Control Register
+ * --------------------------------------
+ * This register controls the settings of the Fan Speed PWM mechanism.
+ */
+#define MLXSW_REG_MFCR_ID 0x9001
+#define MLXSW_REG_MFCR_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_mfcr = {
+	.id = MLXSW_REG_MFCR_ID,
+	.len = MLXSW_REG_MFCR_LEN,
+};
+
+enum mlxsw_reg_mfcr_pwm_frequency {
+	MLXSW_REG_MFCR_PWM_FEQ_11HZ = 0x00,
+	MLXSW_REG_MFCR_PWM_FEQ_14_7HZ = 0x01,
+	MLXSW_REG_MFCR_PWM_FEQ_22_1HZ = 0x02,
+	MLXSW_REG_MFCR_PWM_FEQ_1_4KHZ = 0x40,
+	MLXSW_REG_MFCR_PWM_FEQ_5KHZ = 0x41,
+	MLXSW_REG_MFCR_PWM_FEQ_20KHZ = 0x42,
+	MLXSW_REG_MFCR_PWM_FEQ_22_5KHZ = 0x43,
+	MLXSW_REG_MFCR_PWM_FEQ_25KHZ = 0x44,
+};
+
+/* reg_mfcr_pwm_frequency
+ * Controls the frequency of the PWM signal.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mfcr, pwm_frequency, 0x00, 0, 6);
+
+#define MLXSW_MFCR_TACHOS_MAX 10
+
+/* reg_mfcr_tacho_active
+ * Indicates which of the tachometer is active (bit per tachometer).
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mfcr, tacho_active, 0x04, 16, MLXSW_MFCR_TACHOS_MAX);
+
+#define MLXSW_MFCR_PWMS_MAX 5
+
+/* reg_mfcr_pwm_active
+ * Indicates which of the PWM control is active (bit per PWM).
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mfcr, pwm_active, 0x04, 0, MLXSW_MFCR_PWMS_MAX);
+
+static inline void
+mlxsw_reg_mfcr_pack(char *payload,
+		    enum mlxsw_reg_mfcr_pwm_frequency pwm_frequency)
+{
+	MLXSW_REG_ZERO(mfcr, payload);
+	mlxsw_reg_mfcr_pwm_frequency_set(payload, pwm_frequency);
+}
+
+static inline void
+mlxsw_reg_mfcr_unpack(char *payload,
+		      enum mlxsw_reg_mfcr_pwm_frequency *p_pwm_frequency,
+		      u16 *p_tacho_active, u8 *p_pwm_active)
+{
+	*p_pwm_frequency = mlxsw_reg_mfcr_pwm_frequency_get(payload);
+	*p_tacho_active = mlxsw_reg_mfcr_tacho_active_get(payload);
+	*p_pwm_active = mlxsw_reg_mfcr_pwm_active_get(payload);
+}
+
+/* MFSC - Management Fan Speed Control Register
+ * --------------------------------------------
+ * This register controls the settings of the Fan Speed PWM mechanism.
+ */
+#define MLXSW_REG_MFSC_ID 0x9002
+#define MLXSW_REG_MFSC_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_mfsc = {
+	.id = MLXSW_REG_MFSC_ID,
+	.len = MLXSW_REG_MFSC_LEN,
+};
+
+/* reg_mfsc_pwm
+ * Fan pwm to control / monitor.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mfsc, pwm, 0x00, 24, 3);
+
+/* reg_mfsc_pwm_duty_cycle
+ * Controls the duty cycle of the PWM. Value range from 0..255 to
+ * represent duty cycle of 0%...100%.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mfsc, pwm_duty_cycle, 0x04, 0, 8);
+
+static inline void mlxsw_reg_mfsc_pack(char *payload, u8 pwm,
+				       u8 pwm_duty_cycle)
+{
+	MLXSW_REG_ZERO(mfsc, payload);
+	mlxsw_reg_mfsc_pwm_set(payload, pwm);
+	mlxsw_reg_mfsc_pwm_duty_cycle_set(payload, pwm_duty_cycle);
+}
+
+/* MFSM - Management Fan Speed Measurement
+ * ---------------------------------------
+ * This register controls the settings of the Tacho measurements and
+ * enables reading the Tachometer measurements.
+ */
+#define MLXSW_REG_MFSM_ID 0x9003
+#define MLXSW_REG_MFSM_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_mfsm = {
+	.id = MLXSW_REG_MFSM_ID,
+	.len = MLXSW_REG_MFSM_LEN,
+};
+
+/* reg_mfsm_tacho
+ * Fan tachometer index.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mfsm, tacho, 0x00, 24, 4);
+
+/* reg_mfsm_rpm
+ * Fan speed (round per minute).
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mfsm, rpm, 0x04, 0, 16);
+
+static inline void mlxsw_reg_mfsm_pack(char *payload, u8 tacho)
+{
+	MLXSW_REG_ZERO(mfsm, payload);
+	mlxsw_reg_mfsm_tacho_set(payload, tacho);
+}
+
 /* MTCAP - Management Temperature Capabilities
  * -------------------------------------------
  * This register exposes the capabilities of the device and
@@ -2556,6 +2683,12 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "HTGT";
 	case MLXSW_REG_HPKT_ID:
 		return "HPKT";
+	case MLXSW_REG_MFCR_ID:
+		return "MFCR";
+	case MLXSW_REG_MFSC_ID:
+		return "MFSC";
+	case MLXSW_REG_MFSM_ID:
+		return "MFSM";
 	case MLXSW_REG_MTCAP_ID:
 		return "MTCAP";
 	case MLXSW_REG_MTMP_ID:
-- 
1.9.3
