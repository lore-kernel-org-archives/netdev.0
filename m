From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/9] mlxsw: pci: Add max router interface resource
Date: Tue, 20 Sep 2016 11:16:56 +0200
Message-ID: <1474363017-2901-9-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33188 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932266AbcITJRK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id w84so2316846wmg.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:09 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add the max number of rif (router interfaces) to resource query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h | 4 +++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 5 +++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 097e560..c4f550b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -276,7 +276,8 @@ struct mlxsw_resources {
 		max_virtual_routers_valid:1,
 		max_system_ports_valid:1,
 		max_vlan_groups_valid:1,
-		max_regions_valid:1;
+		max_regions_valid:1,
+		max_rif_valid:1;
 	u8      max_span;
 	u8	max_lag;
 	u8	max_ports_in_lag;
@@ -287,6 +288,7 @@ struct mlxsw_resources {
 	u16	max_system_ports;
 	u16	max_vlan_groups;
 	u16	max_regions;
+	u16	max_rif;
 
 	/* Internal resources.
 	 * Determined by the SW, not queried from the HW.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 826b502..e742bd4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1165,6 +1165,7 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 #define MLXSW_MAX_SYSTEM_PORT_ID 0x2502
 #define MLXSW_MAX_VLAN_GROUPS_ID 0x2906
 #define MLXSW_MAX_REGIONS_ID 0x2901
+#define MLXSW_MAX_RIF_ID 0x2C02
 #define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
 #define MLXSW_RESOURCES_PER_QUERY 32
 
@@ -1212,6 +1213,10 @@ static void mlxsw_pci_resources_query_parse(int id, u64 val,
 		resources->max_regions = val;
 		resources->max_regions_valid = 1;
 		break;
+	case MLXSW_MAX_RIF_ID:
+		resources->max_rif = val;
+		resources->max_rif_valid = 1;
+		break;
 	default:
 		break;
 	}
-- 
2.5.5
