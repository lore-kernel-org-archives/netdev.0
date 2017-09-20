From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/16] mlxsw: spectrum_switchdev: Use generic mc flood function
Date: Wed, 20 Sep 2017 16:15:10 +0200
Message-ID: <20170920141516.1402-11-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38369 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdITOP1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:27 -0400
Received: by mail-wm0-f66.google.com with SMTP id x17so2560679wmd.5
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:27 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Use the generic mc flood function to decide whether to flood mc to a port
when mc is being enabled / disabled.
Move this function in the file to avoid forward declaration.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 79806af..19ac206 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -742,6 +742,14 @@ static int mlxsw_sp_port_attr_mrouter_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
+static bool mlxsw_sp_mc_flood(const struct mlxsw_sp_bridge_port *bridge_port)
+{
+	const struct mlxsw_sp_bridge_device *bridge_device;
+
+	bridge_device = bridge_port->bridge_device;
+	return !bridge_device->multicast_enabled ? true : bridge_port->mrouter;
+}
+
 static int mlxsw_sp_port_mc_disabled_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					 struct switchdev_trans *trans,
 					 struct net_device *orig_dev,
@@ -770,7 +778,7 @@ static int mlxsw_sp_port_mc_disabled_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	list_for_each_entry(bridge_port, &bridge_device->ports_list, list) {
 		enum mlxsw_sp_flood_type packet_type = MLXSW_SP_FLOOD_TYPE_MC;
-		bool member = mc_disabled ? true : bridge_port->mrouter;
+		bool member = mlxsw_sp_mc_flood(bridge_port);
 
 		err = mlxsw_sp_bridge_port_flood_table_set(mlxsw_sp_port,
 							   bridge_port,
@@ -829,14 +837,6 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 	return err;
 }
 
-static bool mlxsw_sp_mc_flood(const struct mlxsw_sp_bridge_port *bridge_port)
-{
-	const struct mlxsw_sp_bridge_device *bridge_device;
-
-	bridge_device = bridge_port->bridge_device;
-	return !bridge_device->multicast_enabled ? true : bridge_port->mrouter;
-}
-
 static int
 mlxsw_sp_port_vlan_fid_join(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 			    struct mlxsw_sp_bridge_port *bridge_port)
-- 
2.9.5
