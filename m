From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] mlxsw: spectrum_dpipe: Make host entry fill handler more generic
Date: Wed, 30 Aug 2017 14:03:03 +0200
Message-ID: <20170830120306.6128-6-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36008 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdH3MDV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id i76so1546303wme.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:20 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Change the host entry filler helper to be applicable for both IPv4/6
addresses.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 93ba6a6..5924e97 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -439,13 +439,12 @@ mlxsw_sp_dpipe_table_host_entry_prepare(struct devlink_dpipe_entry *entry,
 }
 
 static void
-__mlxsw_sp_dpipe_table_host4_entry_fill(struct devlink_dpipe_entry *entry,
-					struct mlxsw_sp_rif *rif,
-					unsigned char *ha, u32 dip)
+__mlxsw_sp_dpipe_table_host_entry_fill(struct devlink_dpipe_entry *entry,
+				       struct mlxsw_sp_rif *rif,
+				       unsigned char *ha, void *dip)
 {
 	struct devlink_dpipe_value *value;
 	u32 *rif_value;
-	u32 *dip_value;
 	u8 *ha_value;
 
 	/* Set Match RIF index */
@@ -458,9 +457,7 @@ __mlxsw_sp_dpipe_table_host4_entry_fill(struct devlink_dpipe_entry *entry,
 
 	/* Set Match DIP */
 	value = &entry->match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
-
-	dip_value = value->value;
-	*dip_value = dip;
+	memcpy(value->value, dip, value->value_size);
 
 	/* Set Action DMAC */
 	value = entry->action_values;
@@ -478,7 +475,7 @@ mlxsw_sp_dpipe_table_host4_entry_fill(struct devlink_dpipe_entry *entry,
 
 	ha = mlxsw_sp_neigh_entry_ha(neigh_entry);
 	dip = mlxsw_sp_neigh4_entry_dip(neigh_entry);
-	__mlxsw_sp_dpipe_table_host4_entry_fill(entry, rif, ha, dip);
+	__mlxsw_sp_dpipe_table_host_entry_fill(entry, rif, ha, &dip);
 }
 
 static void
-- 
2.9.3
