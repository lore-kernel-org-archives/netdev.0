From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/14] mlxsw: reg: Add Router Algorithmic LPM Unicast Entry Register definition
Date: Mon,  4 Jul 2016 08:23:10 +0200
Message-ID: <1467613397-17140-8-git-send-email-jiri@resnulli.us>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34630 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbcGDGXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:30 -0400
Received: by mail-wm0-f66.google.com with SMTP id 187so19172361wmz.1
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:30 -0700 (PDT)
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Serves for adding, updating and removing fib entries.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 264 ++++++++++++++++++++++++++++++
 1 file changed, 264 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0b7b91f..9280d96 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3622,6 +3622,268 @@ static inline void mlxsw_reg_raltb_pack(char *payload, u16 virtual_router,
 	mlxsw_reg_raltb_tree_id_set(payload, tree_id);
 }
 
+/* RALUE - Router Algorithmic LPM Unicast Entry Register
+ * -----------------------------------------------------
+ * RALUE is used to configure and query LPM entries that serve
+ * the Unicast protocols.
+ */
+#define MLXSW_REG_RALUE_ID 0x8013
+#define MLXSW_REG_RALUE_LEN 0x38
+
+static const struct mlxsw_reg_info mlxsw_reg_ralue = {
+	.id = MLXSW_REG_RALUE_ID,
+	.len = MLXSW_REG_RALUE_LEN,
+};
+
+/* reg_ralue_protocol
+ * Protocol.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ralue, protocol, 0x00, 24, 4);
+
+enum mlxsw_reg_ralue_op {
+	/* Read operation. If entry doesn't exist, the operation fails. */
+	MLXSW_REG_RALUE_OP_QUERY_READ = 0,
+	/* Clear on read operation. Used to read entry and
+	 * clear Activity bit.
+	 */
+	MLXSW_REG_RALUE_OP_QUERY_CLEAR = 1,
+	/* Write operation. Used to write a new entry to the table. All RW
+	 * fields are written for new entry. Activity bit is set
+	 * for new entries.
+	 */
+	MLXSW_REG_RALUE_OP_WRITE_WRITE = 0,
+	/* Update operation. Used to update an existing route entry and
+	 * only update the RW fields that are detailed in the field
+	 * op_u_mask. If entry doesn't exist, the operation fails.
+	 */
+	MLXSW_REG_RALUE_OP_WRITE_UPDATE = 1,
+	/* Clear activity. The Activity bit (the field a) is cleared
+	 * for the entry.
+	 */
+	MLXSW_REG_RALUE_OP_WRITE_CLEAR = 2,
+	/* Delete operation. Used to delete an existing entry. If entry
+	 * doesn't exist, the operation fails.
+	 */
+	MLXSW_REG_RALUE_OP_WRITE_DELETE = 3,
+};
+
+/* reg_ralue_op
+ * Operation.
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, ralue, op, 0x00, 20, 3);
+
+/* reg_ralue_a
+ * Activity. Set for new entries. Set if a packet lookup has hit on the
+ * specific entry, only if the entry is a route. To clear the a bit, use
+ * "clear activity" op.
+ * Enabled by activity_dis in RGCR
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, ralue, a, 0x00, 16, 1);
+
+/* reg_ralue_virtual_router
+ * Virtual Router ID
+ * Range is 0..cap_max_virtual_routers-1
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ralue, virtual_router, 0x04, 16, 16);
+
+#define MLXSW_REG_RALUE_OP_U_MASK_ENTRY_TYPE	BIT(0)
+#define MLXSW_REG_RALUE_OP_U_MASK_BMP_LEN	BIT(1)
+#define MLXSW_REG_RALUE_OP_U_MASK_ACTION	BIT(2)
+
+/* reg_ralue_op_u_mask
+ * opcode update mask.
+ * On read operation, this field is reserved.
+ * This field is valid for update opcode, otherwise - reserved.
+ * This field is a bitmask of the fields that should be updated.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, ralue, op_u_mask, 0x04, 8, 3);
+
+/* reg_ralue_prefix_len
+ * Number of bits in the prefix of the LPM route.
+ * Note that for IPv6 prefixes, if prefix_len>64 the entry consumes
+ * two entries in the physical HW table.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ralue, prefix_len, 0x08, 0, 8);
+
+/* reg_ralue_dip*
+ * The prefix of the route or of the marker that the object of the LPM
+ * is compared with. The most significant bits of the dip are the prefix.
+ * The list significant bits must be '0' if the prefix_len is smaller
+ * than 128 for IPv6 or smaller than 32 for IPv4.
+ * IPv4 address uses bits dip[31:0] and bits dip[127:32] are reserved.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ralue, dip4, 0x18, 0, 32);
+
+enum mlxsw_reg_ralue_entry_type {
+	MLXSW_REG_RALUE_ENTRY_TYPE_MARKER_ENTRY = 1,
+	MLXSW_REG_RALUE_ENTRY_TYPE_ROUTE_ENTRY = 2,
+	MLXSW_REG_RALUE_ENTRY_TYPE_MARKER_AND_ROUTE_ENTRY = 3,
+};
+
+/* reg_ralue_entry_type
+ * Entry type.
+ * Note - for Marker entries, the action_type and action fields are reserved.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, entry_type, 0x1C, 30, 2);
+
+/* reg_ralue_bmp_len
+ * The best match prefix length in the case that there is no match for
+ * longer prefixes.
+ * If (entry_type != MARKER_ENTRY), bmp_len must be equal to prefix_len
+ * Note for any update operation with entry_type modification this
+ * field must be set.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, bmp_len, 0x1C, 16, 8);
+
+enum mlxsw_reg_ralue_action_type {
+	MLXSW_REG_RALUE_ACTION_TYPE_REMOTE,
+	MLXSW_REG_RALUE_ACTION_TYPE_LOCAL,
+	MLXSW_REG_RALUE_ACTION_TYPE_IP2ME,
+};
+
+/* reg_ralue_action_type
+ * Action Type
+ * Indicates how the IP address is connected.
+ * It can be connected to a local subnet through local_erif or can be
+ * on a remote subnet connected through a next-hop router,
+ * or transmitted to the CPU.
+ * Reserved when entry_type = MARKER_ENTRY
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, action_type, 0x1C, 0, 2);
+
+enum mlxsw_reg_ralue_trap_action {
+	MLXSW_REG_RALUE_TRAP_ACTION_NOP,
+	MLXSW_REG_RALUE_TRAP_ACTION_TRAP,
+	MLXSW_REG_RALUE_TRAP_ACTION_MIRROR_TO_CPU,
+	MLXSW_REG_RALUE_TRAP_ACTION_MIRROR,
+	MLXSW_REG_RALUE_TRAP_ACTION_DISCARD_ERROR,
+};
+
+/* reg_ralue_trap_action
+ * Trap action.
+ * For IP2ME action, only NOP and MIRROR are possible.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, trap_action, 0x20, 28, 4);
+
+/* reg_ralue_trap_id
+ * Trap ID to be reported to CPU.
+ * Trap ID is RTR_INGRESS0 or RTR_INGRESS1.
+ * For trap_action of NOP, MIRROR and DISCARD_ERROR, trap_id is reserved.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, trap_id, 0x20, 0, 9);
+
+/* reg_ralue_adjacency_index
+ * Points to the first entry of the group-based ECMP.
+ * Only relevant in case of REMOTE action.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, adjacency_index, 0x24, 0, 24);
+
+/* reg_ralue_ecmp_size
+ * Amount of sequential entries starting
+ * from the adjacency_index (the number of ECMPs).
+ * The valid range is 1-64, 512, 1024, 2048 and 4096.
+ * Reserved when trap_action is TRAP or DISCARD_ERROR.
+ * Only relevant in case of REMOTE action.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, ecmp_size, 0x28, 0, 13);
+
+/* reg_ralue_local_erif
+ * Egress Router Interface.
+ * Only relevant in case of LOCAL action.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, local_erif, 0x24, 0, 16);
+
+/* reg_ralue_v
+ * Valid bit for the tunnel_ptr field.
+ * If valid = 0 then trap to CPU as IP2ME trap ID.
+ * If valid = 1 and the packet format allows NVE or IPinIP tunnel
+ * decapsulation then tunnel decapsulation is done.
+ * If valid = 1 and packet format does not allow NVE or IPinIP tunnel
+ * decapsulation then trap as IP2ME trap ID.
+ * Only relevant in case of IP2ME action.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, v, 0x24, 31, 1);
+
+/* reg_ralue_tunnel_ptr
+ * Tunnel Pointer for NVE or IPinIP tunnel decapsulation.
+ * For Spectrum, pointer to KVD Linear.
+ * Only relevant in case of IP2ME action.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralue, tunnel_ptr, 0x24, 0, 24);
+
+static inline void mlxsw_reg_ralue_pack(char *payload,
+					enum mlxsw_reg_ralxx_protocol protocol,
+					enum mlxsw_reg_ralue_op op,
+					u16 virtual_router, u8 prefix_len)
+{
+	MLXSW_REG_ZERO(ralue, payload);
+	mlxsw_reg_ralue_protocol_set(payload, protocol);
+	mlxsw_reg_ralue_virtual_router_set(payload, virtual_router);
+	mlxsw_reg_ralue_prefix_len_set(payload, prefix_len);
+	mlxsw_reg_ralue_entry_type_set(payload,
+				       MLXSW_REG_RALUE_ENTRY_TYPE_ROUTE_ENTRY);
+	mlxsw_reg_ralue_bmp_len_set(payload, prefix_len);
+}
+
+static inline void mlxsw_reg_ralue_pack4(char *payload,
+					 enum mlxsw_reg_ralxx_protocol protocol,
+					 enum mlxsw_reg_ralue_op op,
+					 u16 virtual_router, u8 prefix_len,
+					 u32 dip)
+{
+	mlxsw_reg_ralue_pack(payload, protocol, op, virtual_router, prefix_len);
+	mlxsw_reg_ralue_dip4_set(payload, dip);
+}
+
+static inline void
+mlxsw_reg_ralue_act_remote_pack(char *payload,
+				enum mlxsw_reg_ralue_trap_action trap_action,
+				u16 trap_id, u32 adjacency_index, u16 ecmp_size)
+{
+	mlxsw_reg_ralue_action_type_set(payload,
+					MLXSW_REG_RALUE_ACTION_TYPE_REMOTE);
+	mlxsw_reg_ralue_trap_action_set(payload, trap_action);
+	mlxsw_reg_ralue_trap_id_set(payload, trap_id);
+	mlxsw_reg_ralue_adjacency_index_set(payload, adjacency_index);
+	mlxsw_reg_ralue_ecmp_size_set(payload, ecmp_size);
+}
+
+static inline void
+mlxsw_reg_ralue_act_local_pack(char *payload,
+			       enum mlxsw_reg_ralue_trap_action trap_action,
+			       u16 trap_id, u16 local_erif)
+{
+	mlxsw_reg_ralue_action_type_set(payload,
+					MLXSW_REG_RALUE_ACTION_TYPE_LOCAL);
+	mlxsw_reg_ralue_trap_action_set(payload, trap_action);
+	mlxsw_reg_ralue_trap_id_set(payload, trap_id);
+	mlxsw_reg_ralue_local_erif_set(payload, local_erif);
+}
+
+static inline void
+mlxsw_reg_ralue_act_ip2me_pack(char *payload)
+{
+	mlxsw_reg_ralue_action_type_set(payload,
+					MLXSW_REG_RALUE_ACTION_TYPE_IP2ME);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -4370,6 +4632,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RALST";
 	case MLXSW_REG_RALTB_ID:
 		return "RALTB";
+	case MLXSW_REG_RALUE_ID:
+		return "RALUE";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
