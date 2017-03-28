From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/8] mlxsw: reg: Add counter fields to RITR register
Date: Tue, 28 Mar 2017 17:24:11 +0200
Message-ID: <1490714657-6116-3-git-send-email-jiri@resnulli.us>
References: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33793 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752448AbdC1PZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:25:02 -0400
Received: by mail-wm0-f66.google.com with SMTP id u132so305798wmg.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:24:47 -0700 (PDT)
In-Reply-To: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Update RITR for counter support. This allows adding counters for
ASIC's router ports.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 54 +++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index e7a652c..82aaa3e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4125,6 +4125,60 @@ MLXSW_ITEM32(reg, ritr, sp_if_system_port, 0x08, 0, 16);
  */
 MLXSW_ITEM32(reg, ritr, sp_if_vid, 0x18, 0, 12);
 
+/* Shared between ingress/egress */
+enum mlxsw_reg_ritr_counter_set_type {
+	/* No Count. */
+	MLXSW_REG_RITR_COUNTER_SET_TYPE_NO_COUNT = 0x0,
+	/* Basic. Used for router interfaces, counting the following:
+	 *	- Error and Discard counters.
+	 *	- Unicast, Multicast and Broadcast counters. Sharing the
+	 *	  same set of counters for the different type of traffic
+	 *	  (IPv4, IPv6 and mpls).
+	 */
+	MLXSW_REG_RITR_COUNTER_SET_TYPE_BASIC = 0x9,
+};
+
+/* reg_ritr_ingress_counter_index
+ * Counter Index for flow counter.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ingress_counter_index, 0x38, 0, 24);
+
+/* reg_ritr_ingress_counter_set_type
+ * Igress Counter Set Type for router interface counter.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, ingress_counter_set_type, 0x38, 24, 8);
+
+/* reg_ritr_egress_counter_index
+ * Counter Index for flow counter.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, egress_counter_index, 0x3C, 0, 24);
+
+/* reg_ritr_egress_counter_set_type
+ * Egress Counter Set Type for router interface counter.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, egress_counter_set_type, 0x3C, 24, 8);
+
+static inline void mlxsw_reg_ritr_counter_pack(char *payload, u32 index,
+					       bool enable, bool egress)
+{
+	enum mlxsw_reg_ritr_counter_set_type set_type;
+
+	if (enable)
+		set_type = MLXSW_REG_RITR_COUNTER_SET_TYPE_BASIC;
+	else
+		set_type = MLXSW_REG_RITR_COUNTER_SET_TYPE_NO_COUNT;
+	mlxsw_reg_ritr_egress_counter_set_type_set(payload, set_type);
+
+	if (egress)
+		mlxsw_reg_ritr_egress_counter_index_set(payload, index);
+	else
+		mlxsw_reg_ritr_ingress_counter_index_set(payload, index);
+}
+
 static inline void mlxsw_reg_ritr_rif_pack(char *payload, u16 rif)
 {
 	MLXSW_REG_ZERO(ritr, payload);
-- 
2.7.4
