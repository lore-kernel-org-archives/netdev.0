From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] mlxsw: cmd: Push resource query defines to cmd.h
Date: Fri, 21 Oct 2016 16:07:22 +0200
Message-ID: <1477058843-9981-6-git-send-email-jiri@resnulli.us>
References: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33269 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755755AbcJUOHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:07:35 -0400
Received: by mail-lf0-f68.google.com with SMTP id l131so5840014lfl.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:07:34 -0700 (PDT)
In-Reply-To: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Push cmd resource query related defines to cmd.h where they belong.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h |  5 +++++
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 10 ++++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index 28271be..56e19b0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -513,6 +513,11 @@ static inline int mlxsw_cmd_unmap_fa(struct mlxsw_core *mlxsw_core)
  * are no more sources in the table, will return resource id 0xFFF to indicate
  * it.
  */
+
+#define MLXSW_CMD_QUERY_RESOURCES_TABLE_END_ID 0xffff
+#define MLXSW_CMD_QUERY_RESOURCES_MAX_QUERIES 100
+#define MLXSW_CMD_QUERY_RESOURCES_PER_QUERY 32
+
 static inline int mlxsw_cmd_query_resources(struct mlxsw_core *mlxsw_core,
 					    char *out_mbox, int index)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 6f36806..c3b1663 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1155,7 +1155,6 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 	mlxsw_cmd_mbox_config_profile_swid_config_mask_set(mbox, index, mask);
 }
 
-#define MLXSW_RESOURCES_TABLE_END_ID 0xffff
 #define MLXSW_MAX_SPAN_ID 0x2420
 #define MLXSW_MAX_LAG_ID 0x2520
 #define MLXSW_MAX_PORTS_IN_LAG_ID 0x2521
@@ -1167,8 +1166,6 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 #define MLXSW_MAX_VLAN_GROUPS_ID 0x2906
 #define MLXSW_MAX_REGIONS_ID 0x2901
 #define MLXSW_MAX_RIF_ID 0x2C02
-#define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
-#define MLXSW_RESOURCES_PER_QUERY 32
 
 static void mlxsw_pci_resources_query_parse(int id, u64 val,
 					    struct mlxsw_resources *resources)
@@ -1238,16 +1235,17 @@ static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
 
 	mlxsw_cmd_mbox_zero(mbox);
 
-	for (index = 0; index < MLXSW_RESOURCES_QUERY_MAX_QUERIES; index++) {
+	for (index = 0; index < MLXSW_CMD_QUERY_RESOURCES_MAX_QUERIES;
+	     index++) {
 		err = mlxsw_cmd_query_resources(mlxsw_pci->core, mbox, index);
 		if (err)
 			return err;
 
-		for (i = 0; i < MLXSW_RESOURCES_PER_QUERY; i++) {
+		for (i = 0; i < MLXSW_CMD_QUERY_RESOURCES_PER_QUERY; i++) {
 			id = mlxsw_cmd_mbox_query_resource_id_get(mbox, i);
 			data = mlxsw_cmd_mbox_query_resource_data_get(mbox, i);
 
-			if (id == MLXSW_RESOURCES_TABLE_END_ID)
+			if (id == MLXSW_CMD_QUERY_RESOURCES_TABLE_END_ID)
 				return 0;
 
 			mlxsw_pci_resources_query_parse(id, data, resources);
-- 
2.5.5
