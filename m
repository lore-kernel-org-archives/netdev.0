From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/16] mlxsw: reg: Add eth prefix to PTYS pack and unpack
Date: Fri, 28 Oct 2016 21:35:52 +0200
Message-ID: <1477683361-8011-7-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35208 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756160AbcJ1Tnp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:43:45 -0400
Received: by mail-wm0-f68.google.com with SMTP id 68so1986196wmz.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:43:44 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

We want to add Infiniband support to PTYS. In order to maintain proper
conventions, we will change pack and unpack prefix to eth.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 11 ++++++-----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 17 +++++++++--------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 18 ++++++++++--------
 3 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index debcf26..3ecf348 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2131,8 +2131,8 @@ MLXSW_ITEM32(reg, ptys, eth_proto_oper, 0x24, 0, 32);
  */
 MLXSW_ITEM32(reg, ptys, eth_proto_lp_advertise, 0x30, 0, 32);
 
-static inline void mlxsw_reg_ptys_pack(char *payload, u8 local_port,
-				       u32 proto_admin)
+static inline void mlxsw_reg_ptys_eth_pack(char *payload, u8 local_port,
+					   u32 proto_admin)
 {
 	MLXSW_REG_ZERO(ptys, payload);
 	mlxsw_reg_ptys_local_port_set(payload, local_port);
@@ -2140,9 +2140,10 @@ static inline void mlxsw_reg_ptys_pack(char *payload, u8 local_port,
 	mlxsw_reg_ptys_eth_proto_admin_set(payload, proto_admin);
 }
 
-static inline void mlxsw_reg_ptys_unpack(char *payload, u32 *p_eth_proto_cap,
-					 u32 *p_eth_proto_adm,
-					 u32 *p_eth_proto_oper)
+static inline void mlxsw_reg_ptys_eth_unpack(char *payload,
+					     u32 *p_eth_proto_cap,
+					     u32 *p_eth_proto_adm,
+					     u32 *p_eth_proto_oper)
 {
 	if (p_eth_proto_cap)
 		*p_eth_proto_cap = mlxsw_reg_ptys_eth_proto_cap_get(payload);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d649064..d1c2f9f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2003,12 +2003,12 @@ static int mlxsw_sp_port_get_link_ksettings(struct net_device *dev,
 	int err;
 
 	autoneg = mlxsw_sp_port->link.autoneg;
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
 	if (err)
 		return err;
-	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap, &eth_proto_admin,
-			      &eth_proto_oper);
+	mlxsw_reg_ptys_eth_unpack(ptys_pl, &eth_proto_cap, &eth_proto_admin,
+				  &eth_proto_oper);
 
 	mlxsw_sp_port_get_link_supported(eth_proto_cap, cmd);
 
@@ -2037,11 +2037,11 @@ mlxsw_sp_port_set_link_ksettings(struct net_device *dev,
 	bool autoneg;
 	int err;
 
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
 	if (err)
 		return err;
-	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap, NULL, NULL);
+	mlxsw_reg_ptys_eth_unpack(ptys_pl, &eth_proto_cap, NULL, NULL);
 
 	autoneg = cmd->base.autoneg == AUTONEG_ENABLE;
 	eth_proto_new = autoneg ?
@@ -2054,7 +2054,8 @@ mlxsw_sp_port_set_link_ksettings(struct net_device *dev,
 		return -EINVAL;
 	}
 
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, eth_proto_new);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sp_port->local_port,
+				eth_proto_new);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
 	if (err)
 		return err;
@@ -2092,8 +2093,8 @@ mlxsw_sp_port_speed_by_width_set(struct mlxsw_sp_port *mlxsw_sp_port, u8 width)
 	u32 eth_proto_admin;
 
 	eth_proto_admin = mlxsw_sp_to_ptys_upper_speed(upper_speed);
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port,
-			    eth_proto_admin);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sp_port->local_port,
+				eth_proto_admin);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 44dae8d..7b74dcb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -762,14 +762,14 @@ static int mlxsw_sx_port_get_settings(struct net_device *dev,
 	u32 eth_proto_oper;
 	int err;
 
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
 	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
 	if (err) {
 		netdev_err(dev, "Failed to get proto");
 		return err;
 	}
-	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap,
-			      &eth_proto_admin, &eth_proto_oper);
+	mlxsw_reg_ptys_eth_unpack(ptys_pl, &eth_proto_cap,
+				  &eth_proto_admin, &eth_proto_oper);
 
 	cmd->supported = mlxsw_sx_from_ptys_supported_port(eth_proto_cap) |
 			 mlxsw_sx_from_ptys_supported_link(eth_proto_cap) |
@@ -841,13 +841,14 @@ static int mlxsw_sx_port_set_settings(struct net_device *dev,
 		mlxsw_sx_to_ptys_advert_link(cmd->advertising) :
 		mlxsw_sx_to_ptys_speed(speed);
 
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
 	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
 	if (err) {
 		netdev_err(dev, "Failed to get proto");
 		return err;
 	}
-	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap, &eth_proto_admin, NULL);
+	mlxsw_reg_ptys_eth_unpack(ptys_pl, &eth_proto_cap, &eth_proto_admin,
+				  NULL);
 
 	eth_proto_new = eth_proto_new & eth_proto_cap;
 	if (!eth_proto_new) {
@@ -857,7 +858,8 @@ static int mlxsw_sx_port_set_settings(struct net_device *dev,
 	if (eth_proto_new == eth_proto_admin)
 		return 0;
 
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, eth_proto_new);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sx_port->local_port,
+				eth_proto_new);
 	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
 	if (err) {
 		netdev_err(dev, "Failed to set proto admin");
@@ -977,8 +979,8 @@ mlxsw_sx_port_speed_by_width_set(struct mlxsw_sx_port *mlxsw_sx_port, u8 width)
 	u32 eth_proto_admin;
 
 	eth_proto_admin = mlxsw_sx_to_ptys_upper_speed(upper_speed);
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port,
-			    eth_proto_admin);
+	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sx_port->local_port,
+				eth_proto_admin);
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
 }
 
-- 
2.5.5
