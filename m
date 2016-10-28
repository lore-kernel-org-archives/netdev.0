From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/16] mlxsw: switchx2: Add eth prefix to port create and remove
Date: Fri, 28 Oct 2016 21:35:59 +0200
Message-ID: <1477683361-8011-14-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36226 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761711AbcJ1TuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:50:06 -0400
Received: by mail-wm0-f65.google.com with SMTP id c17so8781362wmc.3
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:50:05 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Since we are about to add Infiniband port remove and create we will add
"eth" prefix to port create and remove APIs.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index d110e3f..3aa0948 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -994,8 +994,8 @@ mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(spmlr), spmlr_pl);
 }
 
-static int __mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
-				  u8 module, u8 width)
+static int __mlxsw_sx_port_eth_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
+				      u8 module, u8 width)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port;
 	struct net_device *dev;
@@ -1119,8 +1119,8 @@ static int __mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 	return err;
 }
 
-static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
-				u8 module, u8 width)
+static int mlxsw_sx_port_eth_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
+				    u8 module, u8 width)
 {
 	int err;
 
@@ -1130,7 +1130,7 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 			local_port);
 		return err;
 	}
-	err = __mlxsw_sx_port_create(mlxsw_sx, local_port, module, width);
+	err = __mlxsw_sx_port_eth_create(mlxsw_sx, local_port, module, width);
 	if (err)
 		goto err_port_create;
 
@@ -1141,7 +1141,7 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 	return err;
 }
 
-static void __mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+static void __mlxsw_sx_port_eth_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = mlxsw_sx->ports[local_port];
 
@@ -1153,9 +1153,9 @@ static void __mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	free_netdev(mlxsw_sx_port->dev);
 }
 
-static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
+static void mlxsw_sx_port_eth_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 {
-	__mlxsw_sx_port_remove(mlxsw_sx, local_port);
+	__mlxsw_sx_port_eth_remove(mlxsw_sx, local_port);
 	mlxsw_core_port_fini(mlxsw_sx->core, local_port);
 }
 
@@ -1170,7 +1170,7 @@ static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
 
 	for (i = 1; i < MLXSW_PORT_MAX_PORTS; i++)
 		if (mlxsw_sx_port_created(mlxsw_sx, i))
-			mlxsw_sx_port_remove(mlxsw_sx, i);
+			mlxsw_sx_port_eth_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
 }
 
@@ -1193,7 +1193,7 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 			goto err_port_module_info_get;
 		if (!width)
 			continue;
-		err = mlxsw_sx_port_create(mlxsw_sx, i, module, width);
+		err = mlxsw_sx_port_eth_create(mlxsw_sx, i, module, width);
 		if (err)
 			goto err_port_create;
 	}
@@ -1203,7 +1203,7 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 err_port_module_info_get:
 	for (i--; i >= 1; i--)
 		if (mlxsw_sx_port_created(mlxsw_sx, i))
-			mlxsw_sx_port_remove(mlxsw_sx, i);
+			mlxsw_sx_port_eth_remove(mlxsw_sx, i);
 	kfree(mlxsw_sx->ports);
 	return err;
 }
-- 
2.5.5
