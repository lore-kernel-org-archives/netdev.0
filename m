From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/6] mlxsw: reg: Add Management LED Control register definition
Date: Fri, 27 Nov 2015 13:45:54 +0100
Message-ID: <1448628359-20077-2-git-send-email-jiri@resnulli.us>
References: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33221 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbbK0MqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 07:46:05 -0500
Received: by wmec201 with SMTP id c201so69055628wme.0
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 04:46:03 -0800 (PST)
In-Reply-To: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Add the MLCR register, which controls physical port identification LEDs.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 46 +++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 236fb5d..fc6839d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2087,6 +2087,50 @@ static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 	mlxsw_reg_hpkt_ctrl_set(payload, MLXSW_REG_HPKT_CTRL_PACKET_DEFAULT);
 }
 
+/* MLCR - Management LED Control Register
+ * --------------------------------------
+ * Controls the system LEDs.
+ */
+#define MLXSW_REG_MLCR_ID 0x902B
+#define MLXSW_REG_MLCR_LEN 0x0C
+
+static const struct mlxsw_reg_info mlxsw_reg_mlcr = {
+	.id = MLXSW_REG_MLCR_ID,
+	.len = MLXSW_REG_MLCR_LEN,
+};
+
+/* reg_mlcr_local_port
+ * Local port number.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mlcr, local_port, 0x00, 16, 8);
+
+#define MLXSW_REG_MLCR_DURATION_MAX 0xFFFF
+
+/* reg_mlcr_beacon_duration
+ * Duration of the beacon to be active, in seconds.
+ * 0x0 - Will turn off the beacon.
+ * 0xFFFF - Will turn on the beacon until explicitly turned off.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mlcr, beacon_duration, 0x04, 0, 16);
+
+/* reg_mlcr_beacon_remain
+ * Remaining duration of the beacon, in seconds.
+ * 0xFFFF indicates an infinite amount of time.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, mlcr, beacon_remain, 0x08, 0, 16);
+
+static inline void mlxsw_reg_mlcr_pack(char *payload, u8 local_port,
+				       bool active)
+{
+	MLXSW_REG_ZERO(mlcr, payload);
+	mlxsw_reg_mlcr_local_port_set(payload, local_port);
+	mlxsw_reg_mlcr_beacon_duration_set(payload, active ?
+					   MLXSW_REG_MLCR_DURATION_MAX : 0);
+}
+
 /* SBPR - Shared Buffer Pools Register
  * -----------------------------------
  * The SBPR configures and retrieves the shared buffer pools and configuration.
@@ -2405,6 +2449,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "HTGT";
 	case MLXSW_REG_HPKT_ID:
 		return "HPKT";
+	case MLXSW_REG_MLCR_ID:
+		return "MLCR";
 	case MLXSW_REG_SBPR_ID:
 		return "SBPR";
 	case MLXSW_REG_SBCM_ID:
-- 
1.9.3
