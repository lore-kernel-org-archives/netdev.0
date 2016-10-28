From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/16] mlxsw: reg: Add local-port to Infiniband port mapping
Date: Fri, 28 Oct 2016 21:35:54 +0200
Message-ID: <1477683361-8011-9-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34571 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755886AbcJ1To1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:44:27 -0400
Received: by mail-wm0-f65.google.com with SMTP id p190so2498863wmp.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:44:26 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

In order to change a port type to Infiniband port we should change his
mapping from local-port to Infiniband. Adding the PLIB (Port Local to
InfiniBand) allows this mapping.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 2f31af0..a61ce34 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2748,6 +2748,27 @@ static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port,
 	mlxsw_reg_ppcnt_prio_tc_set(payload, prio_tc);
 }
 
+/* PLIB - Port Local to InfiniBand Port
+ * ------------------------------------
+ * The PLIB register performs mapping from Local Port into InfiniBand Port.
+ */
+#define MLXSW_REG_PLIB_ID 0x500A
+#define MLXSW_REG_PLIB_LEN 0x10
+
+MLXSW_REG_DEFINE(plib, MLXSW_REG_PLIB_ID, MLXSW_REG_PLIB_LEN);
+
+/* reg_plib_local_port
+ * Local port number.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, plib, local_port, 0x00, 16, 8);
+
+/* reg_plib_ib_port
+ * InfiniBand port remapping for local_port.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, plib, ib_port, 0x00, 0, 8);
+
 /* PPTB - Port Prio To Buffer Register
  * -----------------------------------
  * Configures the switch priority to buffer table.
@@ -5188,6 +5209,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(paos),
 	MLXSW_REG(pfcc),
 	MLXSW_REG(ppcnt),
+	MLXSW_REG(plib),
 	MLXSW_REG(pptb),
 	MLXSW_REG(pbmc),
 	MLXSW_REG(pspa),
-- 
2.5.5
