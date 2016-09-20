From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/9] mlxsw: pci: Add lag related resources to resources query
Date: Tue, 20 Sep 2016 11:16:49 +0200
Message-ID: <1474363017-2901-2-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33032 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752611AbcITJRB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:01 -0400
Received: by mail-wm0-f66.google.com with SMTP id w84so2316086wmg.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:01 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add max lag and max ports in lag resources to resources query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h |  6 +++++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 10 ++++++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index d2e3297..51f27a3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -269,8 +269,12 @@ struct mlxsw_driver {
 };
 
 struct mlxsw_resources {
-	u8	max_span_valid:1;
+	u8	max_span_valid:1,
+		max_lag_valid:1,
+		max_ports_in_lag_valid:1;
 	u8      max_span;
+	u8	max_lag;
+	u8	max_ports_in_lag;
 };
 
 struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 1d1360c..cb284ea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1156,6 +1156,8 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 
 #define MLXSW_RESOURCES_TABLE_END_ID 0xffff
 #define MLXSW_MAX_SPAN_ID 0x2420
+#define MLXSW_MAX_LAG_ID 0x2520
+#define MLXSW_MAX_PORTS_IN_LAG_ID 0x2521
 #define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
 #define MLXSW_RESOURCES_PER_QUERY 32
 
@@ -1167,6 +1169,14 @@ static void mlxsw_pci_resources_query_parse(int id, u64 val,
 		resources->max_span = val;
 		resources->max_span_valid = 1;
 		break;
+	case MLXSW_MAX_LAG_ID:
+		resources->max_lag = val;
+		resources->max_lag_valid = 1;
+		break;
+	case MLXSW_MAX_PORTS_IN_LAG_ID:
+		resources->max_ports_in_lag = val;
+		resources->max_ports_in_lag_valid = 1;
+		break;
 	default:
 		break;
 	}
-- 
2.5.5
