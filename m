From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/9] mlxsw: reg: Add Shared Buffer Internal Buffer register
Date: Thu, 21 Jul 2016 10:19:16 +0200
Message-ID: <1469089160-4239-6-git-send-email-jiri@resnulli.us>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34539 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbcGUITa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:19:30 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so1645994wma.1
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 01:19:29 -0700 (PDT)
In-Reply-To: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The SBIB register configures per port buffer for internal use. This
register is used to configure an egress mirror buffer on the egress port
which does the mirroring.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 41 +++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index b669b04..495e524 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5047,6 +5047,45 @@ static inline void mlxsw_reg_sbsr_rec_unpack(char *payload, int rec_index,
 		mlxsw_reg_sbsr_rec_max_buff_occupancy_get(payload, rec_index);
 }
 
+/* SBIB - Shared Buffer Internal Buffer Register
+ * ---------------------------------------------
+ * The SBIB register configures per port buffers for internal use. The internal
+ * buffers consume memory on the port buffers (note that the port buffers are
+ * used also by PBMC).
+ *
+ * For Spectrum this is used for egress mirroring.
+ */
+#define MLXSW_REG_SBIB_ID 0xB006
+#define MLXSW_REG_SBIB_LEN 0x10
+
+static const struct mlxsw_reg_info mlxsw_reg_sbib = {
+	.id = MLXSW_REG_SBIB_ID,
+	.len = MLXSW_REG_SBIB_LEN,
+};
+
+/* reg_sbib_local_port
+ * Local port number
+ * Not supported for CPU port and router port
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sbib, local_port, 0x00, 16, 8);
+
+/* reg_sbib_buff_size
+ * Units represented in cells
+ * Allowed range is 0 to (cap_max_headroom_size - 1)
+ * Default is 0
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sbib, buff_size, 0x08, 0, 24);
+
+static inline void mlxsw_reg_sbib_pack(char *payload, u8 local_port,
+				       u32 buff_size)
+{
+	MLXSW_REG_ZERO(sbib, payload);
+	mlxsw_reg_sbib_local_port_set(payload, local_port);
+	mlxsw_reg_sbib_buff_size_set(payload, buff_size);
+}
+
 static inline const char *mlxsw_reg_id_str(u16 reg_id)
 {
 	switch (reg_id) {
@@ -5164,6 +5203,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SBMM";
 	case MLXSW_REG_SBSR_ID:
 		return "SBSR";
+	case MLXSW_REG_SBIB_ID:
+		return "SBIB";
 	default:
 		return "*UNKNOWN*";
 	}
-- 
2.5.5
