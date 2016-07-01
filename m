From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 39/42] mlxsw: reg: Add Router Algorithmic LPM ECMP Update Register
Date: Fri,  1 Jul 2016 16:05:07 +0200
Message-ID: <1467381910-3445-40-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33828 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbcGAORs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:17:48 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so5657360wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:17:47 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The RALEU register is used to mass update remote action adjacency index
and ecmp size.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 69 +++++++++++++++++++++++++++++++
 1 file changed, 69 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index a2d7870..0cc1485 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4154,6 +4154,73 @@ static inline void mlxsw_reg_rauht_pack4(char *payload,
 	mlxsw_reg_rauht_dip4_set(payload, dip);
 }
 
+/* RALEU - Router Algorithmic LPM ECMP Update Register
+ * ---------------------------------------------------
+ * The register enables updating the ECMP section in the action for multiple
+ * LPM Unicast entries in a single operation. The update is executed to
+ * all entries of a {virtual router, protocol} tuple using the same ECMP group.
+ */
+#define MLXSW_REG_RALEU_ID 0x8015
+#define MLXSW_REG_RALEU_LEN 0x28
+
+static const struct mlxsw_reg_info mlxsw_reg_raleu = {
+	.id = MLXSW_REG_RALEU_ID,
+	.len = MLXSW_REG_RALEU_LEN,
+};
+
+/* reg_raleu_protocol
+ * Protocol.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, raleu, protocol, 0x00, 24, 4);
+
+/* reg_raleu_virtual_router
+ * Virtual Router ID
+ * Range is 0..cap_max_virtual_routers-1
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, raleu, virtual_router, 0x00, 0, 16);
+
+/* reg_raleu_adjacency_index
+ * Adjacency Index used for matching on the existing entries.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, raleu, adjacency_index, 0x10, 0, 24);
+
+/* reg_raleu_ecmp_size
+ * ECMP Size used for matching on the existing entries.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, raleu, ecmp_size, 0x14, 0, 13);
+
+/* reg_raleu_new_adjacency_index
+ * New Adjacency Index.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, raleu, new_adjacency_index, 0x20, 0, 24);
+
+/* reg_raleu_new_ecmp_size
+ * New ECMP Size.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, raleu, new_ecmp_size, 0x24, 0, 13);
+
+static inline void mlxsw_reg_raleu_pack(char *payload,
+					enum mlxsw_reg_ralxx_protocol protocol,
+					u16 virtual_router,
+					u32 adjacency_index, u16 ecmp_size,
+					u32 new_adjacency_index,
+					u16 new_ecmp_size)
+{
+	MLXSW_REG_ZERO(raleu, payload);
+	mlxsw_reg_raleu_protocol_set(payload, protocol);
+	mlxsw_reg_raleu_virtual_router_set(payload, virtual_router);
+	mlxsw_reg_raleu_adjacency_index_set(payload, adjacency_index);
+	mlxsw_reg_raleu_ecmp_size_set(payload, ecmp_size);
+	mlxsw_reg_raleu_new_adjacency_index_set(payload, new_adjacency_index);
+	mlxsw_reg_raleu_new_ecmp_size_set(payload, new_ecmp_size);
+}
+
 /* RAUHTD - Router Algorithmic LPM Unicast Host Table Dump Register
  * ----------------------------------------------------------------
  * The RAUHTD register allows dumping entries from the Router Unicast Host
@@ -5053,6 +5120,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RALUE";
 	case MLXSW_REG_RAUHT_ID:
 		return "RAUHT";
+	case MLXSW_REG_RALEU_ID:
+		return "RALEU";
 	case MLXSW_REG_RAUHTD_ID:
 		return "RAUHTD";
 	case MLXSW_REG_MFCR_ID:
-- 
2.5.5
