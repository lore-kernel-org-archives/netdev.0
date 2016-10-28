From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/16] mlxsw: core: Add "eth" prefix to mlxsw_core_port_set
Date: Fri, 28 Oct 2016 21:35:57 +0200
Message-ID: <1477683361-8011-12-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35183 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755886AbcJ1Ts6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:48:58 -0400
Received: by mail-wm0-f65.google.com with SMTP id 68so2001602wmz.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:48:58 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Since we are about to introduce IB port APIs, we will add prefixes to
existing APIs.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 8 ++++----
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 6 +++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 5 +++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 4 ++--
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index b50acb1..dcd7202 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1705,9 +1705,9 @@ void mlxsw_core_port_fini(struct mlxsw_core *mlxsw_core, u8 local_port)
 }
 EXPORT_SYMBOL(mlxsw_core_port_fini);
 
-void mlxsw_core_port_set(struct mlxsw_core *mlxsw_core, u8 local_port,
-			 void *port_driver_priv, struct net_device *dev,
-			 bool split, u32 split_group)
+void mlxsw_core_port_eth_set(struct mlxsw_core *mlxsw_core, u8 local_port,
+			     void *port_driver_priv, struct net_device *dev,
+			     bool split, u32 split_group)
 {
 	struct mlxsw_core_port *mlxsw_core_port =
 					&mlxsw_core->ports[local_port];
@@ -1718,7 +1718,7 @@ void mlxsw_core_port_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 		devlink_port_split_set(devlink_port, split_group);
 	devlink_port_type_eth_set(devlink_port, dev);
 }
-EXPORT_SYMBOL(mlxsw_core_port_set);
+EXPORT_SYMBOL(mlxsw_core_port_eth_set);
 
 void mlxsw_core_port_clear(struct mlxsw_core *mlxsw_core, u8 local_port,
 			   void *port_driver_priv)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index f4bbbd4..82866d5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -145,9 +145,9 @@ void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 void *mlxsw_core_port_driver_priv(struct mlxsw_core_port *mlxsw_core_port);
 int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core, u8 local_port);
 void mlxsw_core_port_fini(struct mlxsw_core *mlxsw_core, u8 local_port);
-void mlxsw_core_port_set(struct mlxsw_core *mlxsw_core, u8 local_port,
-			 void *port_driver_priv, struct net_device *dev,
-			 bool split, u32 split_group);
+void mlxsw_core_port_eth_set(struct mlxsw_core *mlxsw_core, u8 local_port,
+			     void *port_driver_priv, struct net_device *dev,
+			     bool split, u32 split_group);
 void mlxsw_core_port_clear(struct mlxsw_core *mlxsw_core, u8 local_port,
 			   void *port_driver_priv);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ad4ff27..8bca020 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2358,8 +2358,9 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_register_netdev;
 	}
 
-	mlxsw_core_port_set(mlxsw_sp->core, mlxsw_sp_port->local_port,
-			    mlxsw_sp_port, dev, mlxsw_sp_port->split, module);
+	mlxsw_core_port_eth_set(mlxsw_sp->core, mlxsw_sp_port->local_port,
+				mlxsw_sp_port, dev, mlxsw_sp_port->split,
+				module);
 	mlxsw_core_schedule_dw(&mlxsw_sp_port->hw_stats.update_dw, 0);
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index a905589..d110e3f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1098,8 +1098,8 @@ static int __mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 		goto err_register_netdev;
 	}
 
-	mlxsw_core_port_set(mlxsw_sx->core, mlxsw_sx_port->local_port,
-			    mlxsw_sx_port, dev, false, 0);
+	mlxsw_core_port_eth_set(mlxsw_sx->core, mlxsw_sx_port->local_port,
+				mlxsw_sx_port, dev, false, 0);
 	mlxsw_sx->ports[local_port] = mlxsw_sx_port;
 	return 0;
 
-- 
2.5.5
