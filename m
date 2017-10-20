From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum_router: Configure TIGCR on init
Date: Fri, 20 Oct 2017 09:16:16 +0200
Message-ID: <20171020071616.1498-3-jiri@resnulli.us>
References: <20171020071616.1498-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:47192 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751718AbdJTHQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 03:16:20 -0400
Received: by mail-wm0-f66.google.com with SMTP id t69so19991878wmt.2
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 00:16:19 -0700 (PDT)
In-Reply-To: <20171020071616.1498-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Spectrum tunnels do not default to ttl of "inherit" like the Linux ones
do. Configure TIGCR on router init so that the TTL of tunnel packets is
copied from the overlay packets.

Fixes: ee954d1a91b2 ("mlxsw: spectrum_router: Support GRE tunnels")
Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c16718d..5189022a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5896,11 +5896,20 @@ static void mlxsw_sp_rifs_fini(struct mlxsw_sp *mlxsw_sp)
 	kfree(mlxsw_sp->router->rifs);
 }
 
+static int
+mlxsw_sp_ipip_config_tigcr(struct mlxsw_sp *mlxsw_sp)
+{
+	char tigcr_pl[MLXSW_REG_TIGCR_LEN];
+
+	mlxsw_reg_tigcr_pack(tigcr_pl, true, 0);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(tigcr), tigcr_pl);
+}
+
 static int mlxsw_sp_ipips_init(struct mlxsw_sp *mlxsw_sp)
 {
 	mlxsw_sp->router->ipip_ops_arr = mlxsw_sp_ipip_ops_arr;
 	INIT_LIST_HEAD(&mlxsw_sp->router->ipip_list);
-	return 0;
+	return mlxsw_sp_ipip_config_tigcr(mlxsw_sp);
 }
 
 static void mlxsw_sp_ipips_fini(struct mlxsw_sp *mlxsw_sp)
-- 
2.9.5
