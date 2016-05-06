From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum: Fix rollback order in LAG join failure
Date: Fri,  6 May 2016 22:18:39 +0200
Message-ID: <1462565920-1959-2-git-send-email-jiri@resnulli.us>
References: <1462565920-1959-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35087 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758634AbcEFUSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:18:44 -0400
Received: by mail-wm0-f68.google.com with SMTP id e201so10433260wme.2
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:18:43 -0700 (PDT)
In-Reply-To: <1462565920-1959-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Make the leave procedure in the error path symmetric to the join
procedure and first remove the port from the collector before
potentially destroying the LAG.

Fixes: 0d65fc13042f ("mlxsw: spectrum: Implement LAG port join/leave")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4afbc3e..668b2f4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2541,11 +2541,11 @@ static int mlxsw_sp_port_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	lag->ref_count++;
 	return 0;
 
+err_col_port_enable:
+	mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
 err_col_port_add:
 	if (!lag->ref_count)
 		mlxsw_sp_lag_destroy(mlxsw_sp, lag_id);
-err_col_port_enable:
-	mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
 	return err;
 }
 
-- 
2.5.5
