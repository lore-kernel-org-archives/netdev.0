From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] mlxsw: spectrum_router: Move mlxsw_sp_netdev_ipip_type()
Date: Mon, 16 Oct 2017 16:26:36 +0200
Message-ID: <20171016142639.2453-3-jiri@resnulli.us>
References: <20171016142639.2453-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:44483 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753198AbdJPO0o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:26:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id 196so5331712wma.1
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 07:26:43 -0700 (PDT)
In-Reply-To: <20171016142639.2453-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 38 +++++++++++-----------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 6a356f4..c5e574b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1295,6 +1295,25 @@ mlxsw_sp_ipip_entry_find_by_decap(struct mlxsw_sp *mlxsw_sp,
 	return NULL;
 }
 
+static bool mlxsw_sp_netdev_ipip_type(const struct mlxsw_sp *mlxsw_sp,
+				      const struct net_device *dev,
+				      enum mlxsw_sp_ipip_type *p_type)
+{
+	struct mlxsw_sp_router *router = mlxsw_sp->router;
+	const struct mlxsw_sp_ipip_ops *ipip_ops;
+	enum mlxsw_sp_ipip_type ipipt;
+
+	for (ipipt = 0; ipipt < MLXSW_SP_IPIP_TYPE_MAX; ++ipipt) {
+		ipip_ops = router->ipip_ops_arr[ipipt];
+		if (dev->type == ipip_ops->dev_type) {
+			if (p_type)
+				*p_type = ipipt;
+			return true;
+		}
+	}
+	return false;
+}
+
 struct mlxsw_sp_neigh_key {
 	struct neighbour *n;
 };
@@ -2785,25 +2804,6 @@ static void mlxsw_sp_nexthop_neigh_fini(struct mlxsw_sp *mlxsw_sp,
 	neigh_release(n);
 }
 
-static bool mlxsw_sp_netdev_ipip_type(const struct mlxsw_sp *mlxsw_sp,
-				      const struct net_device *dev,
-				      enum mlxsw_sp_ipip_type *p_type)
-{
-	struct mlxsw_sp_router *router = mlxsw_sp->router;
-	const struct mlxsw_sp_ipip_ops *ipip_ops;
-	enum mlxsw_sp_ipip_type ipipt;
-
-	for (ipipt = 0; ipipt < MLXSW_SP_IPIP_TYPE_MAX; ++ipipt) {
-		ipip_ops = router->ipip_ops_arr[ipipt];
-		if (dev->type == ipip_ops->dev_type) {
-			if (p_type)
-				*p_type = ipipt;
-			return true;
-		}
-	}
-	return false;
-}
-
 static int mlxsw_sp_nexthop_ipip_init(struct mlxsw_sp *mlxsw_sp,
 				      enum mlxsw_sp_ipip_type ipipt,
 				      struct mlxsw_sp_nexthop *nh,
-- 
2.9.5
