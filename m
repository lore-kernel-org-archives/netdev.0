From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/16] mlxsw: spectrum_switchdev: Change mc_router to mrouter
Date: Wed, 20 Sep 2017 16:15:01 +0200
Message-ID: <20170920141516.1402-2-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33550 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdITOPT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:19 -0400
Received: by mail-wm0-f66.google.com with SMTP id m127so2592370wmm.0
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:18 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change the naming of mc_router to mrouter to keep consistency.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index d39ffbf..22f8d74 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -699,10 +699,10 @@ static int mlxsw_sp_port_attr_br_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return -EINVAL;
 }
 
-static int mlxsw_sp_port_attr_mc_router_set(struct mlxsw_sp_port *mlxsw_sp_port,
-					    struct switchdev_trans *trans,
-					    struct net_device *orig_dev,
-					    bool is_port_mc_router)
+static int mlxsw_sp_port_attr_mrouter_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					  struct switchdev_trans *trans,
+					  struct net_device *orig_dev,
+					  bool is_port_mrouter)
 {
 	struct mlxsw_sp_bridge_port *bridge_port;
 	int err;
@@ -720,12 +720,12 @@ static int mlxsw_sp_port_attr_mc_router_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	err = mlxsw_sp_bridge_port_flood_table_set(mlxsw_sp_port, bridge_port,
 						   MLXSW_SP_FLOOD_TYPE_MC,
-						   is_port_mc_router);
+						   is_port_mrouter);
 	if (err)
 		return err;
 
 out:
-	bridge_port->mrouter = is_port_mc_router;
+	bridge_port->mrouter = is_port_mrouter;
 	return 0;
 }
 
@@ -793,9 +793,9 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 						     attr->u.vlan_filtering);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_MROUTER:
-		err = mlxsw_sp_port_attr_mc_router_set(mlxsw_sp_port, trans,
-						       attr->orig_dev,
-						       attr->u.mrouter);
+		err = mlxsw_sp_port_attr_mrouter_set(mlxsw_sp_port, trans,
+						     attr->orig_dev,
+						     attr->u.mrouter);
 		break;
 	case SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED:
 		err = mlxsw_sp_port_mc_disabled_set(mlxsw_sp_port, trans,
-- 
2.9.5
