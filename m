From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 6/8] mlxsw: reg: Add Router Interface Counter Register
Date: Thu, 16 Feb 2017 16:22:42 +0100
Message-ID: <1487258564-3775-7-git-send-email-jiri@resnulli.us>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36212 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932439AbdBPPWy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:22:54 -0500
Received: by mail-wr0-f195.google.com with SMTP id z61so1659908wrc.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:22:53 -0800 (PST)
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The RICNT register retrieves per port performance counter. It will be
used to query the router interfaces statistics.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 124 ++++++++++++++++++++++++++++++
 1 file changed, 124 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 6066689..a3b95a9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4339,6 +4339,129 @@ static inline void mlxsw_reg_ratr_eth_entry_pack(char *payload,
 	mlxsw_reg_ratr_eth_destination_mac_memcpy_to(payload, dest_mac);
 }
 
+/* RICNT - Router Interface Counter Register
+ * -----------------------------------------
+ * The RICNT register retrieves per port performance counters
+ */
+#define MLXSW_REG_RICNT_ID 0x800B
+#define MLXSW_REG_RICNT_LEN 0x100
+
+MLXSW_REG_DEFINE(ricnt, MLXSW_REG_RICNT_ID, MLXSW_REG_RICNT_LEN);
+
+/* reg_ricnt_counter_index
+ * Counter index
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ricnt, counter_index, 0x04, 0, 24);
+
+enum mlxsw_reg_ricnt_counter_set_type {
+	/* No Count. */
+	MLXSW_REG_RICNT_COUNTER_SET_TYPE_NO_COUNT = 0x00,
+	/* Basic. Used for router interfaces, counting the following:
+	 *	- Error and Discard counters.
+	 *	- Unicast, Multicast and Broadcast counters. Sharing the
+	 *	  same set of counters for the different type of traffic
+	 *	  (IPv4, IPv6 and mpls).
+	 */
+	MLXSW_REG_RICNT_COUNTER_SET_TYPE_BASIC = 0x09,
+};
+
+/* reg_ricnt_counter_set_type
+ * Counter Set Type for router interface counter
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ricnt, counter_set_type, 0x04, 24, 8);
+
+enum mlxsw_reg_ricnt_opcode {
+	/* Nop. Supported only for read access*/
+	MLXSW_REG_RICNT_OPCODE_NOP = 0x00,
+	/* Clear. Setting the clr bit will reset the counter value for
+	 * all counters of the specified Router Interface.
+	 */
+	MLXSW_REG_RICNT_OPCODE_CLEAR = 0x08,
+};
+
+/* reg_ricnt_opcode
+ * Opcode
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ricnt, op, 0x00, 28, 4);
+
+/* reg_ricnt_good_unicast_packets
+ * good unicast packets.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, good_unicast_packets, 0x08, 0, 64);
+
+/* reg_ricnt_good_multicast_packets
+ * good multicast packets.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, good_multicast_packets, 0x10, 0, 64);
+
+/* reg_ricnt_good_broadcast_packets
+ * good broadcast packets
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, good_broadcast_packets, 0x18, 0, 64);
+
+/* reg_ricnt_good_unicast_bytes
+ * A count of L3 data and padding octets not including L2 headers
+ * for good unicast frames.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, good_unicast_bytes, 0x20, 0, 64);
+
+/* reg_ricnt_good_multicast_bytes
+ * A count of L3 data and padding octets not including L2 headers
+ * for good multicast frames.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, good_multicast_bytes, 0x28, 0, 64);
+
+/* reg_ritr_good_broadcast_bytes
+ * A count of L3 data and padding octets not including L2 headers
+ * for good broadcast frames.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, good_broadcast_bytes, 0x30, 0, 64);
+
+/* reg_ricnt_error_packets
+ * A count of errored frames that do not pass the router checks.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, error_packets, 0x38, 0, 64);
+
+/* reg_ricnt_discrad_packets
+ * A count of non-errored frames that do not pass the router checks.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, discard_packets, 0x40, 0, 64);
+
+/* reg_ricnt_error_bytes
+ * A count of L3 data and padding octets not including L2 headers
+ * for errored frames.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, error_bytes, 0x48, 0, 64);
+
+/* reg_ricnt_discard_bytes
+ * A count of L3 data and padding octets not including L2 headers
+ * for non-errored frames that do not pass the router checks.
+ * Access: RW
+ */
+MLXSW_ITEM64(reg, ricnt, discard_bytes, 0x50, 0, 64);
+
+static inline void mlxsw_reg_ricnt_pack(char *payload, u32 index,
+					enum mlxsw_reg_ricnt_opcode op)
+{
+	MLXSW_REG_ZERO(ricnt, payload);
+	mlxsw_reg_ricnt_op_set(payload, op);
+	mlxsw_reg_ricnt_counter_index_set(payload, index);
+	mlxsw_reg_ricnt_counter_set_type_set(payload,
+					     MLXSW_REG_RICNT_COUNTER_SET_TYPE_BASIC);
+}
+
 /* RALTA - Router Algorithmic LPM Tree Allocation Register
  * -------------------------------------------------------
  * RALTA is used to allocate the LPM trees of the SHSPM method.
@@ -6014,6 +6137,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(rgcr),
 	MLXSW_REG(ritr),
 	MLXSW_REG(ratr),
+	MLXSW_REG(ricnt),
 	MLXSW_REG(ralta),
 	MLXSW_REG(ralst),
 	MLXSW_REG(raltb),
-- 
2.7.4
