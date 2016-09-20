From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/9] mlxsw: pci: Add KVD size relate resources
Date: Tue, 20 Sep 2016 11:16:51 +0200
Message-ID: <1474363017-2901-4-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33076 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754248AbcITJRE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:04 -0400
Received: by mail-wm0-f68.google.com with SMTP id w84so2316289wmg.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:03 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add KVD size, and minimum sizes for the single and double
sections resources to resources query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h |  8 +++++++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 15 +++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 558d1ce..76ad566 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -267,10 +267,16 @@ struct mlxsw_driver {
 struct mlxsw_resources {
 	u8	max_span_valid:1,
 		max_lag_valid:1,
-		max_ports_in_lag_valid:1;
+		max_ports_in_lag_valid:1,
+		kvd_size_valid:1,
+		kvd_single_min_size_valid:1,
+		kvd_double_min_size_valid:1;
 	u8      max_span;
 	u8	max_lag;
 	u8	max_ports_in_lag;
+	u32	kvd_size;
+	u32	kvd_single_min_size;
+	u32	kvd_double_min_size;
 };
 
 struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 57c2d34..7b2ab1e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1158,6 +1158,9 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 #define MLXSW_MAX_SPAN_ID 0x2420
 #define MLXSW_MAX_LAG_ID 0x2520
 #define MLXSW_MAX_PORTS_IN_LAG_ID 0x2521
+#define MLXSW_KVD_SIZE_ID 0x1001
+#define MLXSW_KVD_SINGLE_MIN_SIZE_ID 0x1002
+#define MLXSW_KVD_DOUBLE_MIN_SIZE_ID 0x1003
 #define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
 #define MLXSW_RESOURCES_PER_QUERY 32
 
@@ -1177,6 +1180,18 @@ static void mlxsw_pci_resources_query_parse(int id, u64 val,
 		resources->max_ports_in_lag = val;
 		resources->max_ports_in_lag_valid = 1;
 		break;
+	case MLXSW_KVD_SIZE_ID:
+		resources->kvd_size = val;
+		resources->kvd_size_valid = 1;
+		break;
+	case MLXSW_KVD_SINGLE_MIN_SIZE_ID:
+		resources->kvd_single_min_size = val;
+		resources->kvd_single_min_size_valid = 1;
+		break;
+	case MLXSW_KVD_DOUBLE_MIN_SIZE_ID:
+		resources->kvd_double_min_size = val;
+		resources->kvd_double_min_size_valid = 1;
+		break;
 	default:
 		break;
 	}
-- 
2.5.5
