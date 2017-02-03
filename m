From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/19] mlxsw: reg: Add Policy-Engine TCAM Entry Register Version 2
Date: Fri,  3 Feb 2017 10:28:56 +0100
Message-ID: <1486114149-7941-7-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33820 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752512AbdBCJ3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:19 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so3103245wmi.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:18 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The PTCE-V2 register is used for accessing rules within a TCAM region.
It is a new version of PTCE in order to support wider key, mask and
action within a TCAM region.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 100 ++++++++++++++++++++++++++++++
 1 file changed, 100 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 444f0a3..1008251 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1957,6 +1957,105 @@ static inline void mlxsw_reg_ptar_unpack(char *payload, char *tcam_region_info)
 	mlxsw_reg_ptar_tcam_region_info_memcpy_from(payload, tcam_region_info);
 }
 
+/* PTCE-V2 - Policy-Engine TCAM Entry Register Version 2
+ * -----------------------------------------------------
+ * This register is used for accessing rules within a TCAM region.
+ * It is a new version of PTCE in order to support wider key,
+ * mask and action within a TCAM region. This register is not supported
+ * by SwitchX and SwitchX-2.
+ */
+#define MLXSW_REG_PTCE2_ID 0x3017
+#define MLXSW_REG_PTCE2_LEN 0x1D8
+
+MLXSW_REG_DEFINE(ptce2, MLXSW_REG_PTCE2_ID, MLXSW_REG_PTCE2_LEN);
+
+/* reg_ptce2_v
+ * Valid.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ptce2, v, 0x00, 31, 1);
+
+/* reg_ptce2_a
+ * Activity. Set if a packet lookup has hit on the specific entry.
+ * To clear the "a" bit, use "clear activity" op or "clear on read" op.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ptce2, a, 0x00, 30, 1);
+
+enum mlxsw_reg_ptce2_op {
+	/* Read operation. */
+	MLXSW_REG_PTCE2_OP_QUERY_READ = 0,
+	/* clear on read operation. Used to read entry
+	 * and clear Activity bit.
+	 */
+	MLXSW_REG_PTCE2_OP_QUERY_CLEAR_ON_READ = 1,
+	/* Write operation. Used to write a new entry to the table.
+	 * All R/W fields are relevant for new entry. Activity bit is set
+	 * for new entries - Note write with v = 0 will delete the entry.
+	 */
+	MLXSW_REG_PTCE2_OP_WRITE_WRITE = 0,
+	/* Update action. Only action set will be updated. */
+	MLXSW_REG_PTCE2_OP_WRITE_UPDATE = 1,
+	/* Clear activity. A bit is cleared for the entry. */
+	MLXSW_REG_PTCE2_OP_WRITE_CLEAR_ACTIVITY = 2,
+};
+
+/* reg_ptce2_op
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, ptce2, op, 0x00, 20, 3);
+
+/* reg_ptce2_offset
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ptce2, offset, 0x00, 0, 16);
+
+/* reg_ptce2_tcam_region_info
+ * Opaque object that represents the TCAM region.
+ * Access: Index
+ */
+MLXSW_ITEM_BUF(reg, ptce2, tcam_region_info, 0x10,
+	       MLXSW_REG_PXXX_TCAM_REGION_INFO_LEN);
+
+#define MLXSW_REG_PTCE2_FLEX_KEY_BLOCKS_LEN 96
+
+/* reg_ptce2_flex_key_blocks
+ * ACL Key.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, ptce2, flex_key_blocks, 0x20,
+	       MLXSW_REG_PTCE2_FLEX_KEY_BLOCKS_LEN);
+
+/* reg_ptce2_mask
+ * mask- in the same size as key. A bit that is set directs the TCAM
+ * to compare the corresponding bit in key. A bit that is clear directs
+ * the TCAM to ignore the corresponding bit in key.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, ptce2, mask, 0x80,
+	       MLXSW_REG_PTCE2_FLEX_KEY_BLOCKS_LEN);
+
+#define MLXSW_REG_PTCE2_FLEX_ACTION_SET_LEN 0xA8
+
+/* reg_ptce2_flex_action_set
+ * ACL action set.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, ptce2, flex_action_set, 0xE0,
+	       MLXSW_REG_PTCE2_FLEX_ACTION_SET_LEN);
+
+static inline void mlxsw_reg_ptce2_pack(char *payload, bool valid,
+					enum mlxsw_reg_ptce2_op op,
+					const char *tcam_region_info,
+					u16 offset)
+{
+	MLXSW_REG_ZERO(ptce2, payload);
+	mlxsw_reg_ptce2_v_set(payload, valid);
+	mlxsw_reg_ptce2_op_set(payload, op);
+	mlxsw_reg_ptce2_offset_set(payload, offset);
+	mlxsw_reg_ptce2_tcam_region_info_memcpy_to(payload, tcam_region_info);
+}
+
 /* QPCR - QoS Policer Configuration Register
  * -----------------------------------------
  * The QPCR register is used to create policers - that limit
@@ -5637,6 +5736,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(pacl),
 	MLXSW_REG(pagt),
 	MLXSW_REG(ptar),
+	MLXSW_REG(ptce2),
 	MLXSW_REG(qpcr),
 	MLXSW_REG(qtct),
 	MLXSW_REG(qeec),
-- 
2.7.4
