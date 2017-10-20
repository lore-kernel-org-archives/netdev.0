From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: reg: Add Tunneling IPinIP General Configuration Register
Date: Fri, 20 Oct 2017 09:16:15 +0200
Message-ID: <20171020071616.1498-2-jiri@resnulli.us>
References: <20171020071616.1498-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:52286 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751779AbdJTHQT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 03:16:19 -0400
Received: by mail-wm0-f68.google.com with SMTP id k4so20496520wmc.1
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 00:16:18 -0700 (PDT)
In-Reply-To: <20171020071616.1498-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

The TIGCR register is used for setting up the IPinIP Tunnel
configuration.

Fixes: ee954d1a91b2 ("mlxsw: spectrum_router: Support GRE tunnels")
Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index cc27c5d..4afc848 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -6401,6 +6401,36 @@ static inline void mlxsw_reg_mgpc_pack(char *payload, u32 counter_index,
 	mlxsw_reg_mgpc_opcode_set(payload, opcode);
 }
 
+/* TIGCR - Tunneling IPinIP General Configuration Register
+ * -------------------------------------------------------
+ * The TIGCR register is used for setting up the IPinIP Tunnel configuration.
+ */
+#define MLXSW_REG_TIGCR_ID 0xA801
+#define MLXSW_REG_TIGCR_LEN 0x10
+
+MLXSW_REG_DEFINE(tigcr, MLXSW_REG_TIGCR_ID, MLXSW_REG_TIGCR_LEN);
+
+/* reg_tigcr_ipip_ttlc
+ * For IPinIP Tunnel encapsulation: whether to copy the ttl from the packet
+ * header.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, tigcr, ttlc, 0x04, 8, 1);
+
+/* reg_tigcr_ipip_ttl_uc
+ * The TTL for IPinIP Tunnel encapsulation of unicast packets if
+ * reg_tigcr_ipip_ttlc is unset.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, tigcr, ttl_uc, 0x04, 0, 8);
+
+static inline void mlxsw_reg_tigcr_pack(char *payload, bool ttlc, u8 ttl_uc)
+{
+	MLXSW_REG_ZERO(tigcr, payload);
+	mlxsw_reg_tigcr_ttlc_set(payload, ttlc);
+	mlxsw_reg_tigcr_ttl_uc_set(payload, ttl_uc);
+}
+
 /* SBPR - Shared Buffer Pools Register
  * -----------------------------------
  * The SBPR configures and retrieves the shared buffer pools and configuration.
@@ -6881,6 +6911,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mcc),
 	MLXSW_REG(mcda),
 	MLXSW_REG(mgpc),
+	MLXSW_REG(tigcr),
 	MLXSW_REG(sbpr),
 	MLXSW_REG(sbcm),
 	MLXSW_REG(sbpm),
-- 
2.9.5
