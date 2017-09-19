From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/13] mlxsw: reg: Add The Router TCAM Allocation register
Date: Tue, 19 Sep 2017 10:00:13 +0200
Message-ID: <20170919080020.5870-7-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35384 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751227AbdISIA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:29 -0400
Received: by mail-wm0-f66.google.com with SMTP id e64so3064007wmi.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:28 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

This register is used for allocation of regions in the TCAM table and it
will be used by the multicast router offloading logic.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 52 +++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index fb8ab44..e9f37ea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4310,6 +4310,57 @@ mlxsw_reg_ritr_loopback_ipip4_pack(char *payload,
 	mlxsw_reg_ritr_loopback_ipip_usip4_set(payload, usip);
 }
 
+/* RTAR - Router TCAM Allocation Register
+ * --------------------------------------
+ * This register is used for allocation of regions in the TCAM table.
+ */
+#define MLXSW_REG_RTAR_ID 0x8004
+#define MLXSW_REG_RTAR_LEN 0x20
+
+MLXSW_REG_DEFINE(rtar, MLXSW_REG_RTAR_ID, MLXSW_REG_RTAR_LEN);
+
+enum mlxsw_reg_rtar_op {
+	MLXSW_REG_RTAR_OP_ALLOCATE,
+	MLXSW_REG_RTAR_OP_RESIZE,
+	MLXSW_REG_RTAR_OP_DEALLOCATE,
+};
+
+/* reg_rtar_op
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, rtar, op, 0x00, 28, 4);
+
+enum mlxsw_reg_rtar_key_type {
+	MLXSW_REG_RTAR_KEY_TYPE_IPV4_MULTICAST = 1,
+	MLXSW_REG_RTAR_KEY_TYPE_IPV6_MULTICAST = 3
+};
+
+/* reg_rtar_key_type
+ * TCAM key type for the region.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, rtar, key_type, 0x00, 0, 8);
+
+/* reg_rtar_region_size
+ * TCAM region size. When allocating/resizing this is the requested
+ * size, the response is the actual size.
+ * Note: Actual size may be larger than requested.
+ * Reserved for op = Deallocate
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, rtar, region_size, 0x04, 0, 16);
+
+static inline void mlxsw_reg_rtar_pack(char *payload,
+				       enum mlxsw_reg_rtar_op op,
+				       enum mlxsw_reg_rtar_key_type key_type,
+				       u16 region_size)
+{
+	MLXSW_REG_ZERO(rtar, payload);
+	mlxsw_reg_rtar_op_set(payload, op);
+	mlxsw_reg_rtar_key_type_set(payload, key_type);
+	mlxsw_reg_rtar_region_size_set(payload, region_size);
+}
+
 /* RATR - Router Adjacency Table Register
  * --------------------------------------
  * The RATR register is used to configure the Router Adjacency (next-hop)
@@ -6855,6 +6906,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(hpkt),
 	MLXSW_REG(rgcr),
 	MLXSW_REG(ritr),
+	MLXSW_REG(rtar),
 	MLXSW_REG(ratr),
 	MLXSW_REG(rtdp),
 	MLXSW_REG(ricnt),
-- 
2.9.5
