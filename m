From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/22] mlxsw: spectrum_router: Mark IPv4 specific function accordingly
Date: Tue, 18 Jul 2017 10:10:27 +0200
Message-ID: <20170718081030.2781-20-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33059 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdGRILD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:11:03 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so1462408wrd.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:11:02 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The functions to create and destroy a nexthop group are IPv4 specific
and should be renamed accordingly, so that they won't be confused with
the IPv6 specific functions in follow-up patches.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 58 +++++++++++-----------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 52487a4..5d787c1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1868,10 +1868,10 @@ static void mlxsw_sp_nexthop_neigh_fini(struct mlxsw_sp *mlxsw_sp,
 	neigh_release(n);
 }
 
-static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_nexthop_group *nh_grp,
-				 struct mlxsw_sp_nexthop *nh,
-				 struct fib_nh *fib_nh)
+static int mlxsw_sp_nexthop4_init(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_nexthop_group *nh_grp,
+				  struct mlxsw_sp_nexthop *nh,
+				  struct fib_nh *fib_nh)
 {
 	struct net_device *dev = fib_nh->nh_dev;
 	struct in_device *in_dev;
@@ -1910,16 +1910,16 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	return err;
 }
 
-static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
-				  struct mlxsw_sp_nexthop *nh)
+static void mlxsw_sp_nexthop4_fini(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_nexthop *nh)
 {
 	mlxsw_sp_nexthop_neigh_fini(mlxsw_sp, nh);
 	mlxsw_sp_nexthop_rif_fini(nh);
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
-static void mlxsw_sp_nexthop_event(struct mlxsw_sp *mlxsw_sp,
-				   unsigned long event, struct fib_nh *fib_nh)
+static void mlxsw_sp_nexthop4_event(struct mlxsw_sp *mlxsw_sp,
+				    unsigned long event, struct fib_nh *fib_nh)
 {
 	struct mlxsw_sp_nexthop_key key;
 	struct mlxsw_sp_nexthop *nh;
@@ -1964,7 +1964,7 @@ static void mlxsw_sp_nexthop_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
 }
 
 static struct mlxsw_sp_nexthop_group *
-mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
+mlxsw_sp_nexthop4_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 {
 	struct mlxsw_sp_nexthop_group *nh_grp;
 	struct mlxsw_sp_nexthop *nh;
@@ -1988,9 +1988,9 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 	for (i = 0; i < nh_grp->count; i++) {
 		nh = &nh_grp->nexthops[i];
 		fib_nh = &fi->fib_nh[i];
-		err = mlxsw_sp_nexthop_init(mlxsw_sp, nh_grp, nh, fib_nh);
+		err = mlxsw_sp_nexthop4_init(mlxsw_sp, nh_grp, nh, fib_nh);
 		if (err)
-			goto err_nexthop_init;
+			goto err_nexthop4_init;
 	}
 	err = mlxsw_sp_nexthop_group_insert(mlxsw_sp, nh_grp);
 	if (err)
@@ -1999,10 +1999,10 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 	return nh_grp;
 
 err_nexthop_group_insert:
-err_nexthop_init:
+err_nexthop4_init:
 	for (i--; i >= 0; i--) {
 		nh = &nh_grp->nexthops[i];
-		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
+		mlxsw_sp_nexthop4_fini(mlxsw_sp, nh);
 	}
 	fib_info_put(nh_grp->key.fi);
 	kfree(nh_grp);
@@ -2010,8 +2010,8 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 }
 
 static void
-mlxsw_sp_nexthop_group_destroy(struct mlxsw_sp *mlxsw_sp,
-			       struct mlxsw_sp_nexthop_group *nh_grp)
+mlxsw_sp_nexthop4_group_destroy(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_nexthop_group *nh_grp)
 {
 	struct mlxsw_sp_nexthop *nh;
 	int i;
@@ -2019,7 +2019,7 @@ mlxsw_sp_nexthop_group_destroy(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_nexthop_group_remove(mlxsw_sp, nh_grp);
 	for (i = 0; i < nh_grp->count; i++) {
 		nh = &nh_grp->nexthops[i];
-		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
+		mlxsw_sp_nexthop4_fini(mlxsw_sp, nh);
 	}
 	mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh_grp);
 	WARN_ON_ONCE(nh_grp->adj_index_valid);
@@ -2027,9 +2027,9 @@ mlxsw_sp_nexthop_group_destroy(struct mlxsw_sp *mlxsw_sp,
 	kfree(nh_grp);
 }
 
-static int mlxsw_sp_nexthop_group_get(struct mlxsw_sp *mlxsw_sp,
-				      struct mlxsw_sp_fib_entry *fib_entry,
-				      struct fib_info *fi)
+static int mlxsw_sp_nexthop4_group_get(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_fib_entry *fib_entry,
+				       struct fib_info *fi)
 {
 	struct mlxsw_sp_nexthop_group_key key;
 	struct mlxsw_sp_nexthop_group *nh_grp;
@@ -2037,7 +2037,7 @@ static int mlxsw_sp_nexthop_group_get(struct mlxsw_sp *mlxsw_sp,
 	key.fi = fi;
 	nh_grp = mlxsw_sp_nexthop_group_lookup(mlxsw_sp, key);
 	if (!nh_grp) {
-		nh_grp = mlxsw_sp_nexthop_group_create(mlxsw_sp, fi);
+		nh_grp = mlxsw_sp_nexthop4_group_create(mlxsw_sp, fi);
 		if (IS_ERR(nh_grp))
 			return PTR_ERR(nh_grp);
 	}
@@ -2046,15 +2046,15 @@ static int mlxsw_sp_nexthop_group_get(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-static void mlxsw_sp_nexthop_group_put(struct mlxsw_sp *mlxsw_sp,
-				       struct mlxsw_sp_fib_entry *fib_entry)
+static void mlxsw_sp_nexthop4_group_put(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct mlxsw_sp_nexthop_group *nh_grp = fib_entry->nh_group;
 
 	list_del(&fib_entry->nexthop_group_node);
 	if (!list_empty(&nh_grp->fib_list))
 		return;
-	mlxsw_sp_nexthop_group_destroy(mlxsw_sp, nh_grp);
+	mlxsw_sp_nexthop4_group_destroy(mlxsw_sp, nh_grp);
 }
 
 static bool
@@ -2322,9 +2322,9 @@ mlxsw_sp_fib4_entry_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_fib4_entry_type_set;
 
-	err = mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fen_info->fi);
+	err = mlxsw_sp_nexthop4_group_get(mlxsw_sp, fib_entry, fen_info->fi);
 	if (err)
-		goto err_nexthop_group_get;
+		goto err_nexthop4_group_get;
 
 	fib4_entry->prio = fen_info->fi->fib_priority;
 	fib4_entry->tb_id = fen_info->tb_id;
@@ -2335,7 +2335,7 @@ mlxsw_sp_fib4_entry_create(struct mlxsw_sp *mlxsw_sp,
 
 	return fib4_entry;
 
-err_nexthop_group_get:
+err_nexthop4_group_get:
 err_fib4_entry_type_set:
 	kfree(fib4_entry);
 	return ERR_PTR(err);
@@ -2344,7 +2344,7 @@ mlxsw_sp_fib4_entry_create(struct mlxsw_sp *mlxsw_sp,
 static void mlxsw_sp_fib4_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 					struct mlxsw_sp_fib4_entry *fib4_entry)
 {
-	mlxsw_sp_nexthop_group_put(mlxsw_sp, &fib4_entry->common);
+	mlxsw_sp_nexthop4_group_put(mlxsw_sp, &fib4_entry->common);
 	kfree(fib4_entry);
 }
 
@@ -3022,8 +3022,8 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
-		mlxsw_sp_nexthop_event(mlxsw_sp, fib_work->event,
-				       fib_work->fnh_info.fib_nh);
+		mlxsw_sp_nexthop4_event(mlxsw_sp, fib_work->event,
+					fib_work->fnh_info.fib_nh);
 		fib_info_put(fib_work->fnh_info.fib_nh->nh_parent);
 		break;
 	}
-- 
2.9.3
