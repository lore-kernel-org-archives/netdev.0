From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/13] mlxsw: reg: Add the Router Multicast Forwarding Table Version 2 register
Date: Tue, 19 Sep 2017 10:00:16 +0200
Message-ID: <20170919080020.5870-10-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34124 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751619AbdISIAb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:31 -0400
Received: by mail-wr0-f193.google.com with SMTP id k20so1712402wre.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:30 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The RMFT-V2 register is used to configure and query the multicast table and
will be used by the multicast router offloading logic.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 142 ++++++++++++++++++++++++++++++
 1 file changed, 142 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 1778d7f..046525e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5728,6 +5728,147 @@ static inline void mlxsw_reg_rigr2_erif_entry_pack(char *payload, int index,
 	mlxsw_reg_rigr2_erif_entry_erif_set(payload, index, erif);
 }
 
+/* RMFT-V2 - Router Multicast Forwarding Table Version 2 Register
+ * --------------------------------------------------------------
+ * The RMFT_V2 register is used to configure and query the multicast table.
+ */
+#define MLXSW_REG_RMFT2_ID 0x8027
+#define MLXSW_REG_RMFT2_LEN 0x174
+
+MLXSW_REG_DEFINE(rmft2, MLXSW_REG_RMFT2_ID, MLXSW_REG_RMFT2_LEN);
+
+/* reg_rmft2_v
+ * Valid
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, v, 0x00, 31, 1);
+
+enum mlxsw_reg_rmft2_type {
+	MLXSW_REG_RMFT2_TYPE_IPV4,
+	MLXSW_REG_RMFT2_TYPE_IPV6
+};
+
+/* reg_rmft2_type
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rmft2, type, 0x00, 28, 2);
+
+enum mlxsw_sp_reg_rmft2_op {
+	/* For Write:
+	 * Write operation. Used to write a new entry to the table. All RW
+	 * fields are relevant for new entry. Activity bit is set for new
+	 * entries - Note write with v (Valid) 0 will delete the entry.
+	 * For Query:
+	 * Read operation
+	 */
+	MLXSW_REG_RMFT2_OP_READ_WRITE,
+};
+
+/* reg_rmft2_op
+ * Operation.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, rmft2, op, 0x00, 20, 2);
+
+/* reg_rmft2_a
+ * Activity. Set for new entries. Set if a packet lookup has hit on the specific
+ * entry.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, rmft2, a, 0x00, 16, 1);
+
+/* reg_rmft2_offset
+ * Offset within the multicast forwarding table to write to.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rmft2, offset, 0x00, 0, 16);
+
+/* reg_rmft2_virtual_router
+ * Virtual Router ID. Range from 0..cap_max_virtual_routers-1
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, virtual_router, 0x04, 0, 16);
+
+enum mlxsw_reg_rmft2_irif_mask {
+	MLXSW_REG_RMFT2_IRIF_MASK_IGNORE,
+	MLXSW_REG_RMFT2_IRIF_MASK_COMPARE
+};
+
+/* reg_rmft2_irif_mask
+ * Ingress RIF mask.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, irif_mask, 0x08, 24, 1);
+
+/* reg_rmft2_irif
+ * Ingress RIF index.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, irif, 0x08, 0, 16);
+
+/* reg_rmft2_dip4
+ * Destination IPv4 address
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, dip4, 0x1C, 0, 32);
+
+/* reg_rmft2_dip4_mask
+ * A bit that is set directs the TCAM to compare the corresponding bit in key. A
+ * bit that is clear directs the TCAM to ignore the corresponding bit in key.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, dip4_mask, 0x2C, 0, 32);
+
+/* reg_rmft2_sip4
+ * Source IPv4 address
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, sip4, 0x3C, 0, 32);
+
+/* reg_rmft2_sip4_mask
+ * A bit that is set directs the TCAM to compare the corresponding bit in key. A
+ * bit that is clear directs the TCAM to ignore the corresponding bit in key.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rmft2, sip4_mask, 0x4C, 0, 32);
+
+/* reg_rmft2_flexible_action_set
+ * ACL action set. The only supported action types in this field and in any
+ * action-set pointed from here are as follows:
+ * 00h: ACTION_NULL
+ * 01h: ACTION_MAC_TTL, only TTL configuration is supported.
+ * 03h: ACTION_TRAP
+ * 06h: ACTION_QOS
+ * 08h: ACTION_POLICING_MONITORING
+ * 10h: ACTION_ROUTER_MC
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, rmft2, flexible_action_set, 0x80,
+	       MLXSW_REG_FLEX_ACTION_SET_LEN);
+
+static inline void
+mlxsw_reg_rmft2_ipv4_pack(char *payload, bool v, u16 offset, u16 virtual_router,
+			  enum mlxsw_reg_rmft2_irif_mask irif_mask, u16 irif,
+			  u32 dip4, u32 dip4_mask, u32 sip4, u32 sip4_mask,
+			  const char *flexible_action_set)
+{
+	MLXSW_REG_ZERO(rmft2, payload);
+	mlxsw_reg_rmft2_v_set(payload, v);
+	mlxsw_reg_rmft2_type_set(payload, MLXSW_REG_RMFT2_TYPE_IPV4);
+	mlxsw_reg_rmft2_op_set(payload, MLXSW_REG_RMFT2_OP_READ_WRITE);
+	mlxsw_reg_rmft2_offset_set(payload, offset);
+	mlxsw_reg_rmft2_virtual_router_set(payload, virtual_router);
+	mlxsw_reg_rmft2_irif_mask_set(payload, irif_mask);
+	mlxsw_reg_rmft2_irif_set(payload, irif);
+	mlxsw_reg_rmft2_dip4_set(payload, dip4);
+	mlxsw_reg_rmft2_dip4_mask_set(payload, dip4_mask);
+	mlxsw_reg_rmft2_sip4_set(payload, sip4);
+	mlxsw_reg_rmft2_sip4_mask_set(payload, sip4_mask);
+	if (flexible_action_set)
+		mlxsw_reg_rmft2_flexible_action_set_memcpy_to(payload,
+							      flexible_action_set);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -7000,6 +7141,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(raleu),
 	MLXSW_REG(rauhtd),
 	MLXSW_REG(rigr2),
+	MLXSW_REG(rmft2),
 	MLXSW_REG(mfcr),
 	MLXSW_REG(mfsc),
 	MLXSW_REG(mfsm),
-- 
2.9.5
