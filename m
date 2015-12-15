From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/14] mlxsw: spectrum: Use appropriate parameter name
Date: Tue, 15 Dec 2015 16:03:38 +0100
Message-ID: <1450191827-6679-6-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37112 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933457AbbLOPD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:03:59 -0500
Received: by mail-wm0-f51.google.com with SMTP id n186so30041129wmn.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:03:58 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The __mlxsw_sp_port_flood_set function is now used to configure flooding
for both FIDs and vFIDs, so change the parameter name to 'idx' instead
of 'fid'. This is also consistent with hardware documentation.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 67052ea..a8c35ed 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -125,13 +125,13 @@ static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 fid_begin, u16 fid_end, bool set,
+				     u16 idx_begin, u16 idx_end, bool set,
 				     bool only_uc)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u16 local_port = mlxsw_sp_port->local_port;
 	enum mlxsw_flood_table_type table_type;
-	u16 range = fid_end - fid_begin + 1;
+	u16 range = idx_end - idx_begin + 1;
 	char *sftr_pl;
 	int err;
 
@@ -146,7 +146,7 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sftr_pl)
 		return -ENOMEM;
 
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, fid_begin,
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, idx_begin,
 			    table_type, range, local_port, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 	if (err)
@@ -158,7 +158,7 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (only_uc)
 		goto buffer_out;
 
-	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, fid_begin,
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, idx_begin,
 			    table_type, range, local_port, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 
-- 
1.9.3
