From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/12] mlxsw: reg: Make flow counter set type enum to be shared
Date: Thu, 24 Aug 2017 08:40:07 +0200
Message-ID: <20170824064010.1646-10-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34713 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbdHXGk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:28 -0400
Received: by mail-wr0-f195.google.com with SMTP id f6so964235wra.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:28 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This is done as a preparation before introducing support for neighbor
counters. The flow counter's type enum is used by many registers, yet,
until now it was used only by mgpc and thus it was private. This patch
updates the namespace for more generic usage.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 20 ++++++++++----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  4 ++--
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 7e8ba54..bcf55f6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5000,6 +5000,15 @@ enum mlxsw_reg_rauht_trap_id {
  */
 MLXSW_ITEM32(reg, rauht, trap_id, 0x60, 0, 9);
 
+enum mlxsw_reg_flow_counter_set_type {
+	/* No count */
+	MLXSW_REG_FLOW_COUNTER_SET_TYPE_NO_COUNT = 0x00,
+	/* Count packets and bytes */
+	MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS_BYTES = 0x03,
+	/* Count only packets */
+	MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS = 0x05,
+};
+
 /* reg_rauht_counter_set_type
  * Counter set type for flow counters
  * Access: RW
@@ -6041,15 +6050,6 @@ static inline void mlxsw_reg_mpsc_pack(char *payload, u8 local_port, bool e,
 
 MLXSW_REG_DEFINE(mgpc, MLXSW_REG_MGPC_ID, MLXSW_REG_MGPC_LEN);
 
-enum mlxsw_reg_mgpc_counter_set_type {
-	/* No count */
-	MLXSW_REG_MGPC_COUNTER_SET_TYPE_NO_COUT = 0x00,
-	/* Count packets and bytes */
-	MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS_BYTES = 0x03,
-	/* Count only packets */
-	MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS = 0x05,
-};
-
 /* reg_mgpc_counter_set_type
  * Counter set type.
  * Access: OP
@@ -6089,7 +6089,7 @@ MLXSW_ITEM64(reg, mgpc, packet_counter, 0x10, 0, 64);
 
 static inline void mlxsw_reg_mgpc_pack(char *payload, u32 counter_index,
 				       enum mlxsw_reg_mgpc_opcode opcode,
-				       enum mlxsw_reg_mgpc_counter_set_type set_type)
+				       enum mlxsw_reg_flow_counter_set_type set_type)
 {
 	MLXSW_REG_ZERO(mgpc, payload);
 	mlxsw_reg_mgpc_counter_index_set(payload, counter_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6e641db..5332b8f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -382,7 +382,7 @@ int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
 	int err;
 
 	mlxsw_reg_mgpc_pack(mgpc_pl, counter_index, MLXSW_REG_MGPC_OPCODE_NOP,
-			    MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS_BYTES);
+			    MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS_BYTES);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(mgpc), mgpc_pl);
 	if (err)
 		return err;
@@ -397,7 +397,7 @@ static int mlxsw_sp_flow_counter_clear(struct mlxsw_sp *mlxsw_sp,
 	char mgpc_pl[MLXSW_REG_MGPC_LEN];
 
 	mlxsw_reg_mgpc_pack(mgpc_pl, counter_index, MLXSW_REG_MGPC_OPCODE_CLEAR,
-			    MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS_BYTES);
+			    MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS_BYTES);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mgpc), mgpc_pl);
 }
 
-- 
2.9.3
