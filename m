From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/42] mlxsw: reg: Add Router Algorithmic LPM Tree Allocation Register definition
Date: Fri,  1 Jul 2016 16:04:45 +0200
Message-ID: <1467381910-3445-18-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36200 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbcGAOU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:20:27 -0400
Received: by mail-wm0-f65.google.com with SMTP id c82so5666266wme.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:20:26 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Register serves for allocation and deallocation of LPM search tree.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 54 ++++++++++++++++++++++++++++++-
 1 file changed, 53 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 5ddc1d3..a358e1b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3,7 +3,7 @@
  * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
  * Copyright (c) 2015-2016 Ido Schimmel <idosch@mellanox.com>
  * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
- * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015-2016 Jiri Pirko <jiri@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -3454,6 +3454,56 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	mlxsw_reg_ritr_if_mac_memcpy_to(payload, mac);
 }
 
+/* RALTA - Router Algorithmic LPM Tree Allocation Register
+ * -------------------------------------------------------
+ * RALTA is used to allocate the LPM trees of the SHSPM method.
+ */
+#define MLXSW_REG_RALTA_ID 0x8010
+#define MLXSW_REG_RALTA_LEN 0x04
+
+static const struct mlxsw_reg_info mlxsw_reg_ralta = {
+	.id = MLXSW_REG_RALTA_ID,
+	.len = MLXSW_REG_RALTA_LEN,
+};
+
+/* reg_ralta_op
+ * opcode (valid for Write, must be 0 on Read)
+ * 0 - allocate a tree
+ * 1 - deallocate a tree
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, ralta, op, 0x00, 28, 2);
+
+enum mlxsw_reg_ralxx_protocol {
+	MLXSW_REG_RALXX_PROTOCOL_IPV4,
+	MLXSW_REG_RALXX_PROTOCOL_IPV6,
+};
+
+/* reg_ralta_protocol
+ * Protocol.
+ * Deallocation opcode: Reserved.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ralta, protocol, 0x00, 24, 4);
+
+/* reg_ralta_tree_id
+ * An identifier (numbered from 1..cap_shspm_max_trees-1) representing
+ * the tree identifier (managed by software).
+ * Note that tree_id 0 is allocated for a default-route tree.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ralta, tree_id, 0x00, 0, 8);
+
+static inline void mlxsw_reg_ralta_pack(char *payload, bool alloc,
+					enum mlxsw_reg_ralxx_protocol protocol,
+					u8 tree_id)
+{
+	MLXSW_REG_ZERO(ralta, payload);
+	mlxsw_reg_ralta_op_set(payload, !alloc);
+	mlxsw_reg_ralta_protocol_set(payload, protocol);
+	mlxsw_reg_ralta_tree_id_set(payload, tree_id);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -4196,6 +4246,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RGCR";
 	case MLXSW_REG_RITR_ID:
 		return "RITR";
+	case MLXSW_REG_RALTA_ID:
+		return "RALTA";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
