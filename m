From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] mlxsw: spectrum: fix some error handling
Date: Wed, 9 Dec 2015 13:33:51 +0300
Message-ID: <20151209103351.GI3173@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29440 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218AbbLIKeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 05:34:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "err = " assignment is missing here.

Fixes: 0d65fc13042f ('mlxsw: spectrum: Implement LAG port join/leave')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3ec07b9..322ed54 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2091,7 +2091,7 @@ static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	err = mlxsw_sp_lag_col_port_disable(mlxsw_sp_port, lag_id);
 	if (err)
 		return err;
-	mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
+	err = mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
 	if (err)
 		return err;
 
