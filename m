From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/16] mlxsw: Enable configuration of flooding domains
Date: Fri, 16 Oct 2015 14:01:23 +0200
Message-ID: <1444996897-2708-3-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36492 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbbJPMBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:43 -0400
Received: by wicgb1 with SMTP id gb1so6385658wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:42 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As part of the introduction of L2 offloads, allow different ports to
join/leave the flooding domain, according to user configuration.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 6 +++---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 7b245af..4099d4b3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -363,7 +363,7 @@ static inline void mlxsw_reg_sftr_pack(char *payload,
 				       unsigned int flood_table,
 				       unsigned int index,
 				       enum mlxsw_flood_table_type table_type,
-				       unsigned int range)
+				       unsigned int range, u8 port, bool set)
 {
 	MLXSW_REG_ZERO(sftr, payload);
 	mlxsw_reg_sftr_swid_set(payload, 0);
@@ -371,8 +371,8 @@ static inline void mlxsw_reg_sftr_pack(char *payload,
 	mlxsw_reg_sftr_index_set(payload, index);
 	mlxsw_reg_sftr_table_type_set(payload, table_type);
 	mlxsw_reg_sftr_range_set(payload, range);
-	mlxsw_reg_sftr_port_set(payload, MLXSW_PORT_CPU_PORT, 1);
-	mlxsw_reg_sftr_port_mask_set(payload, MLXSW_PORT_CPU_PORT, 1);
+	mlxsw_reg_sftr_port_set(payload, port, set);
+	mlxsw_reg_sftr_port_mask_set(payload, port, 1);
 }
 
 /* SPMLR - Switch Port MAC Learning Register
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 176c159..50e29c4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1377,7 +1377,8 @@ static int mlxsw_sx_flood_init(struct mlxsw_sx *mlxsw_sx)
 	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
 	if (!sftr_pl)
 		return -ENOMEM;
-	mlxsw_reg_sftr_pack(sftr_pl, 0, 0, MLXSW_REG_SFGC_TABLE_TYPE_SINGLE, 0);
+	mlxsw_reg_sftr_pack(sftr_pl, 0, 0, MLXSW_REG_SFGC_TABLE_TYPE_SINGLE, 0,
+			    MLXSW_PORT_CPU_PORT, true);
 	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sftr), sftr_pl);
 	kfree(sftr_pl);
 	if (err)
-- 
1.9.3
