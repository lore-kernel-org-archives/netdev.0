From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/19] mlxsw: reg: Add Policy-Engine ACL Register
Date: Thu,  2 Feb 2017 16:12:43 +0100
Message-ID: <1486048379-19237-4-git-send-email-jiri@resnulli.us>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34399 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdBBPNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:13:06 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so4689559wmi.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 07:13:05 -0800 (PST)
In-Reply-To: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The PACL register is used for configuration of the ACL.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 47 +++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 9fb0316..18b2da4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1,9 +1,9 @@
 /*
  * drivers/net/ethernet/mellanox/mlxsw/reg.h
- * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2015-2017 Mellanox Technologies. All rights reserved.
  * Copyright (c) 2015-2016 Ido Schimmel <idosch@mellanox.com>
  * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
- * Copyright (c) 2015-2016 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2015-2017 Jiri Pirko <jiri@mellanox.com>
  * Copyright (c) 2016 Yotam Gigi <yotamg@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
@@ -1757,6 +1757,48 @@ static inline void mlxsw_reg_spvmlr_pack(char *payload, u8 local_port,
 	}
 }
 
+/* PACL - Policy-Engine ACL Register
+ * ---------------------------------
+ * This register is used for configuration of the ACL.
+ */
+#define MLXSW_REG_PACL_ID 0x3004
+#define MLXSW_REG_PACL_LEN 0x70
+
+MLXSW_REG_DEFINE(pacl, MLXSW_REG_PACL_ID, MLXSW_REG_PACL_LEN);
+
+/* reg_pacl_v
+ * Valid. Setting the v bit makes the ACL valid. It should not be cleared
+ * while the ACL is bounded to either a port, VLAN or ACL rule.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, pacl, v, 0x00, 24, 1);
+
+/* reg_pacl_acl_id
+ * An identifier representing the ACL (managed by software)
+ * Range 0 .. cap_max_acl_regions - 1
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pacl, acl_id, 0x08, 0, 16);
+
+#define MLXSW_REG_PXXX_TCAM_REGION_INFO_LEN 16
+
+/* reg_pacl_tcam_region_info
+ * Opaque object that represents a TCAM region.
+ * Obtained through PTAR register.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, pacl, tcam_region_info, 0x30,
+	       MLXSW_REG_PXXX_TCAM_REGION_INFO_LEN);
+
+static inline void mlxsw_reg_pacl_pack(char *payload, u16 acl_id,
+				       bool valid, const char *tcam_region_info)
+{
+	MLXSW_REG_ZERO(pacl, payload);
+	mlxsw_reg_pacl_acl_id_set(payload, acl_id);
+	mlxsw_reg_pacl_v_set(payload, valid);
+	mlxsw_reg_pacl_tcam_region_info_memcpy_to(payload, tcam_region_info);
+}
+
 /* QPCR - QoS Policer Configuration Register
  * -----------------------------------------
  * The QPCR register is used to create policers - that limit
@@ -5434,6 +5476,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(svpe),
 	MLXSW_REG(sfmr),
 	MLXSW_REG(spvmlr),
+	MLXSW_REG(pacl),
 	MLXSW_REG(qpcr),
 	MLXSW_REG(qtct),
 	MLXSW_REG(qeec),
-- 
2.7.4
