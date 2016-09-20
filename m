From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/9] mlxsw: pci: Add max virtual routers resource
Date: Tue, 20 Sep 2016 11:16:53 +0200
Message-ID: <1474363017-2901-6-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34599 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754264AbcITJRH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:07 -0400
Received: by mail-wm0-f65.google.com with SMTP id l132so2308947wmf.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:06 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add the max number of virtual routers to resource query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h | 4 +++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 5 +++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 1193bdc..e936dc9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -272,13 +272,15 @@ struct mlxsw_resources {
 		max_ports_in_lag_valid:1,
 		kvd_size_valid:1,
 		kvd_single_min_size_valid:1,
-		kvd_double_min_size_valid:1;
+		kvd_double_min_size_valid:1,
+		max_virtual_routers_valid:1;
 	u8      max_span;
 	u8	max_lag;
 	u8	max_ports_in_lag;
 	u32	kvd_size;
 	u32	kvd_single_min_size;
 	u32	kvd_double_min_size;
+	u16     max_virtual_routers;
 
 	/* Internal resources.
 	 * Determined by the SW, not queried from the HW.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index c2d2fa1..cb95f9a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1161,6 +1161,7 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 #define MLXSW_KVD_SIZE_ID 0x1001
 #define MLXSW_KVD_SINGLE_MIN_SIZE_ID 0x1002
 #define MLXSW_KVD_DOUBLE_MIN_SIZE_ID 0x1003
+#define MLXSW_MAX_VIRTUAL_ROUTERS_ID 0x2C01
 #define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
 #define MLXSW_RESOURCES_PER_QUERY 32
 
@@ -1192,6 +1193,10 @@ static void mlxsw_pci_resources_query_parse(int id, u64 val,
 		resources->kvd_double_min_size = val;
 		resources->kvd_double_min_size_valid = 1;
 		break;
+	case MLXSW_MAX_VIRTUAL_ROUTERS_ID:
+		resources->max_virtual_routers = val;
+		resources->max_virtual_routers_valid = 1;
+		break;
 	default:
 		break;
 	}
-- 
2.5.5
