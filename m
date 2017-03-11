From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/9] mlxsw: reg: Add Monitoring General Purpose Counter Set register
Date: Sat, 11 Mar 2017 09:42:52 +0100
Message-ID: <1489221779-3807-3-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33018 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdCKInF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:05 -0500
Received: by mail-wm0-f66.google.com with SMTP id n11so2248714wma.0
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:04 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The MGPC register retrieves generic flow counter value. It will be
used to query ACL counters.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 65 +++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index eb94a5a..393743c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5506,6 +5506,70 @@ static inline void mlxsw_reg_mpsc_pack(char *payload, u8 local_port, bool e,
 	mlxsw_reg_mpsc_rate_set(payload, rate);
 }
 
+/* MGPC - Monitoring General Purpose Counter Set Register
+ * The MGPC register retrieves and sets the General Purpose Counter Set.
+ */
+#define MLXSW_REG_MGPC_ID 0x9081
+#define MLXSW_REG_MGPC_LEN 0x18
+
+MLXSW_REG_DEFINE(mgpc, MLXSW_REG_MGPC_ID, MLXSW_REG_MGPC_LEN);
+
+enum mlxsw_reg_mgpc_counter_set_type {
+	/* No count */
+	MLXSW_REG_MGPC_COUNTER_SET_TYPE_NO_COUT = 0x00,
+	/* Count packets and bytes */
+	MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS_BYTES = 0x03,
+	/* Count only packets */
+	MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS = 0x05,
+};
+
+/* reg_mgpc_counter_set_type
+ * Counter set type.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, mgpc, counter_set_type, 0x00, 24, 8);
+
+/* reg_mgpc_counter_index
+ * Counter index.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, mgpc, counter_index, 0x00, 0, 24);
+
+enum mlxsw_reg_mgpc_opcode {
+	/* Nop */
+	MLXSW_REG_MGPC_OPCODE_NOP = 0x00,
+	/* Clear counters */
+	MLXSW_REG_MGPC_OPCODE_CLEAR = 0x08,
+};
+
+/* reg_mgpc_opcode
+ * Opcode.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, mgpc, opcode, 0x04, 28, 4);
+
+/* reg_mgpc_byte_counter
+ * Byte counter value.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, mgpc, byte_counter, 0x08, 0, 64);
+
+/* reg_mgpc_packet_counter
+ * Packet counter value.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, mgpc, packet_counter, 0x10, 0, 64);
+
+static inline void mlxsw_reg_mgpc_pack(char *payload, u32 counter_index,
+				       enum mlxsw_reg_mgpc_opcode opcode,
+				       enum mlxsw_reg_mgpc_counter_set_type set_type)
+{
+	MLXSW_REG_ZERO(mgpc, payload);
+	mlxsw_reg_mgpc_counter_index_set(payload, counter_index);
+	mlxsw_reg_mgpc_counter_set_type_set(payload, set_type);
+	mlxsw_reg_mgpc_opcode_set(payload, opcode);
+}
+
 /* SBPR - Shared Buffer Pools Register
  * -----------------------------------
  * The SBPR configures and retrieves the shared buffer pools and configuration.
@@ -5979,6 +6043,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mpar),
 	MLXSW_REG(mlcr),
 	MLXSW_REG(mpsc),
+	MLXSW_REG(mgpc),
 	MLXSW_REG(sbpr),
 	MLXSW_REG(sbcm),
 	MLXSW_REG(sbpm),
-- 
2.7.4
