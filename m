From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/8] mlxsw: reg: Add counter fields to RITR register
Date: Thu, 16 Feb 2017 16:22:39 +0100
Message-ID: <1487258564-3775-4-git-send-email-jiri@resnulli.us>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33110 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932423AbdBPPWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:22:50 -0500
Received: by mail-wm0-f66.google.com with SMTP id v77so3650659wmv.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:22:50 -0800 (PST)
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
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
index 0899e2d..6066689 100644
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
