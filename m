From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/17] mlxsw: reg: Add QoS Switch Traffic Class Table register
Date: Wed,  6 Apr 2016 17:10:07 +0200
Message-ID: <1459955416-23786-9-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34947 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbcDFPKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id a140so14163493wma.2
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:29 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As part of DCB ops we'll have to configure the priority to traffic class
mapping of a port.

Add the QoS Switch Traffic Class Table (QTCT) register, which configures
the mapping between the packet switch priority and traffic class on the
transmit port.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 55 +++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index bc08f8b..2e58c41 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1805,6 +1805,59 @@ static inline void mlxsw_reg_spvmlr_pack(char *payload, u8 local_port,
 	}
 }
 
+/* QTCT - QoS Switch Traffic Class Table
+ * -------------------------------------
+ * Configures the mapping between the packet switch priority and the
+ * traffic class on the transmit port.
+ */
+#define MLXSW_REG_QTCT_ID 0x400A
+#define MLXSW_REG_QTCT_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_qtct = {
+	.id = MLXSW_REG_QTCT_ID,
+	.len = MLXSW_REG_QTCT_LEN,
+};
+
+/* reg_qtct_local_port
+ * Local port number.
+ * Access: Index
+ *
+ * Note: CPU port is not supported.
+ */
+MLXSW_ITEM32(reg, qtct, local_port, 0x00, 16, 8);
+
+/* reg_qtct_sub_port
+ * Virtual port within the physical port.
+ * Should be set to 0 when virtual ports are not enabled on the port.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, qtct, sub_port, 0x00, 8, 8);
+
+/* reg_qtct_switch_prio
+ * Switch priority.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, qtct, switch_prio, 0x00, 0, 4);
+
+/* reg_qtct_tclass
+ * Traffic class.
+ * Default values:
+ * switch_prio 0 : tclass 1
+ * switch_prio 1 : tclass 0
+ * switch_prio i : tclass i, for i > 1
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, qtct, tclass, 0x04, 0, 4);
+
+static inline void mlxsw_reg_qtct_pack(char *payload, u8 local_port,
+				       u8 switch_prio, u8 tclass)
+{
+	MLXSW_REG_ZERO(qtct, payload);
+	mlxsw_reg_qtct_local_port_set(payload, local_port);
+	mlxsw_reg_qtct_switch_prio_set(payload, switch_prio);
+	mlxsw_reg_qtct_tclass_set(payload, tclass);
+}
+
 /* QEEC - QoS ETS Element Configuration Register
  * ---------------------------------------------
  * Configures the ETS elements.
@@ -3491,6 +3544,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SFMR";
 	case MLXSW_REG_SPVMLR_ID:
 		return "SPVMLR";
+	case MLXSW_REG_QTCT_ID:
+		return "QTCT";
 	case MLXSW_REG_QEEC_ID:
 		return "QEEC";
 	case MLXSW_REG_PMLP_ID:
-- 
2.5.5
