From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 09/19] mlxsw: reg: Add Policy-Engine Policy Based Switching Register
Date: Fri,  3 Feb 2017 10:28:59 +0100
Message-ID: <1486114149-7941-10-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35453 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbdBCJ3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:23 -0500
Received: by mail-wm0-f66.google.com with SMTP id u63so3088124wmu.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:23 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The PPBS register retrieves and sets Policy Based Switching Table entries.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 555cb80..c503363 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2019,6 +2019,36 @@ static inline void mlxsw_reg_ptar_unpack(char *payload, char *tcam_region_info)
 	mlxsw_reg_ptar_tcam_region_info_memcpy_from(payload, tcam_region_info);
 }
 
+/* PPBS - Policy-Engine Policy Based Switching Register
+ * ----------------------------------------------------
+ * This register retrieves and sets Policy Based Switching Table entries.
+ */
+#define MLXSW_REG_PPBS_ID 0x300C
+#define MLXSW_REG_PPBS_LEN 0x14
+
+MLXSW_REG_DEFINE(ppbs, MLXSW_REG_PPBS_ID, MLXSW_REG_PPBS_LEN);
+
+/* reg_ppbs_pbs_ptr
+ * Index into the PBS table.
+ * For Spectrum, the index points to the KVD Linear.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ppbs, pbs_ptr, 0x08, 0, 24);
+
+/* reg_ppbs_system_port
+ * Unique port identifier for the final destination of the packet.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ppbs, system_port, 0x10, 0, 16);
+
+static inline void mlxsw_reg_ppbs_pack(char *payload, u32 pbs_ptr,
+				       u16 system_port)
+{
+	MLXSW_REG_ZERO(ppbs, payload);
+	mlxsw_reg_ppbs_pbs_ptr_set(payload, pbs_ptr);
+	mlxsw_reg_ppbs_system_port_set(payload, system_port);
+}
+
 /* PRCR - Policy-Engine Rules Copy Register
  * ----------------------------------------
  * This register is used for accessing rules within a TCAM region.
@@ -5875,6 +5905,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(pacl),
 	MLXSW_REG(pagt),
 	MLXSW_REG(ptar),
+	MLXSW_REG(ppbs),
 	MLXSW_REG(prcr),
 	MLXSW_REG(ptce2),
 	MLXSW_REG(qpcr),
-- 
2.7.4
