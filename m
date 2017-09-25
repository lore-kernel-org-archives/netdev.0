From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/10] mlxsw: reg: Add support for counters on RATR
Date: Mon, 25 Sep 2017 10:32:27 +0200
Message-ID: <20170925083230.1193-8-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:38822 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932617AbdIYIch (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:37 -0400
Received: by mail-wr0-f195.google.com with SMTP id p37so1436192wrb.5
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:37 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

In order to add the ability for setting counters on nexthops the RATR
register should be extended.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 44 ++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 17eba19..d44e673 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4549,6 +4549,27 @@ MLXSW_ITEM32(reg, ratr, ipip_ipv4_udip, 0x18, 0, 32);
  */
 MLXSW_ITEM32(reg, ratr, ipip_ipv6_ptr, 0x1C, 0, 24);
 
+enum mlxsw_reg_flow_counter_set_type {
+	/* No count */
+	MLXSW_REG_FLOW_COUNTER_SET_TYPE_NO_COUNT = 0x00,
+	/* Count packets and bytes */
+	MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS_BYTES = 0x03,
+	/* Count only packets */
+	MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS = 0x05,
+};
+
+/* reg_ratr_counter_set_type
+ * Counter set type for flow counters
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, counter_set_type, 0x28, 24, 8);
+
+/* reg_ratr_counter_index
+ * Counter index for flow counters
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ratr, counter_index, 0x28, 0, 24);
+
 static inline void
 mlxsw_reg_ratr_pack(char *payload,
 		    enum mlxsw_reg_ratr_op op, bool valid,
@@ -4576,6 +4597,20 @@ static inline void mlxsw_reg_ratr_ipip4_entry_pack(char *payload, u32 ipv4_udip)
 	mlxsw_reg_ratr_ipip_ipv4_udip_set(payload, ipv4_udip);
 }
 
+static inline void mlxsw_reg_ratr_counter_pack(char *payload, u64 counter_index,
+					       bool counter_enable)
+{
+	enum mlxsw_reg_flow_counter_set_type set_type;
+
+	if (counter_enable)
+		set_type = MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS_BYTES;
+	else
+		set_type = MLXSW_REG_FLOW_COUNTER_SET_TYPE_NO_COUNT;
+
+	mlxsw_reg_ratr_counter_index_set(payload, counter_index);
+	mlxsw_reg_ratr_counter_set_type_set(payload, set_type);
+}
+
 /* RICNT - Router Interface Counter Register
  * -----------------------------------------
  * The RICNT register retrieves per port performance counters
@@ -5297,15 +5332,6 @@ enum mlxsw_reg_rauht_trap_id {
  */
 MLXSW_ITEM32(reg, rauht, trap_id, 0x60, 0, 9);
 
-enum mlxsw_reg_flow_counter_set_type {
-	/* No count */
-	MLXSW_REG_FLOW_COUNTER_SET_TYPE_NO_COUNT = 0x00,
-	/* Count packets and bytes */
-	MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS_BYTES = 0x03,
-	/* Count only packets */
-	MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS = 0x05,
-};
-
 /* reg_rauht_counter_set_type
  * Counter set type for flow counters
  * Access: RW
-- 
2.9.5
