From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/22] mlxsw: reg: Update RAUHTD register with IPv6 support
Date: Tue, 18 Jul 2017 10:10:16 +0200
Message-ID: <20170718081030.2781-9-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32873 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdGRIKs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:48 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so1460885wrd.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:47 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Update the register so that the active IPv6 neighbours could be dumped
from the device's neighbour table.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 32 +++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index abfa631..0fc2263 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5232,6 +5232,30 @@ MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv4_ent_rif, MLXSW_REG_RAUHTD_BASE_LEN, 0,
 MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv4_ent_dip, MLXSW_REG_RAUHTD_BASE_LEN, 0,
 		     32, MLXSW_REG_RAUHTD_IPV4_ENT_LEN, 0x04, false);
 
+#define MLXSW_REG_RAUHTD_IPV6_ENT_LEN 0x20
+
+/* reg_rauhtd_ipv6_ent_a
+ * Activity. Set for new entries. Set if a packet lookup has hit on the
+ * specific entry.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv6_ent_a, MLXSW_REG_RAUHTD_BASE_LEN, 16, 1,
+		     MLXSW_REG_RAUHTD_IPV6_ENT_LEN, 0x00, false);
+
+/* reg_rauhtd_ipv6_ent_rif
+ * Router interface.
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, rauhtd, ipv6_ent_rif, MLXSW_REG_RAUHTD_BASE_LEN, 0,
+		     16, MLXSW_REG_RAUHTD_IPV6_ENT_LEN, 0x00, false);
+
+/* reg_rauhtd_ipv6_ent_dip
+ * Destination IPv6 address.
+ * Access: RO
+ */
+MLXSW_ITEM_BUF_INDEXED(reg, rauhtd, ipv6_ent_dip, MLXSW_REG_RAUHTD_BASE_LEN,
+		       16, MLXSW_REG_RAUHTD_IPV6_ENT_LEN, 0x10);
+
 static inline void mlxsw_reg_rauhtd_ent_ipv4_unpack(char *payload,
 						    int ent_index, u16 *p_rif,
 						    u32 *p_dip)
@@ -5240,6 +5264,14 @@ static inline void mlxsw_reg_rauhtd_ent_ipv4_unpack(char *payload,
 	*p_dip = mlxsw_reg_rauhtd_ipv4_ent_dip_get(payload, ent_index);
 }
 
+static inline void mlxsw_reg_rauhtd_ent_ipv6_unpack(char *payload,
+						    int rec_index, u16 *p_rif,
+						    char *p_dip)
+{
+	*p_rif = mlxsw_reg_rauhtd_ipv6_ent_rif_get(payload, rec_index);
+	mlxsw_reg_rauhtd_ipv6_ent_dip_memcpy_from(payload, rec_index, p_dip);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
-- 
2.9.3
