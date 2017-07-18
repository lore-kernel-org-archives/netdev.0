From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 21/22] mlxsw: spectrum_router: Rename functions to add / delete a FIB entry
Date: Tue, 18 Jul 2017 10:10:29 +0200
Message-ID: <20170718081030.2781-22-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34496 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdGRILG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:11:06 -0400
Received: by mail-wr0-f193.google.com with SMTP id w4so2854835wrb.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:11:05 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

These functions aren't specific to IPv4 and can be re-used for IPv6.

Drop the '4' designation from their name.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c8c8187..32ed2b6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2672,8 +2672,8 @@ mlxsw_sp_fib4_node_list_remove(struct mlxsw_sp_fib4_entry *fib4_entry)
 	list_del(&fib4_entry->common.list);
 }
 
-static int mlxsw_sp_fib4_node_entry_add(struct mlxsw_sp *mlxsw_sp,
-					struct mlxsw_sp_fib_entry *fib_entry)
+static int mlxsw_sp_fib_node_entry_add(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
 
@@ -2693,8 +2693,8 @@ static int mlxsw_sp_fib4_node_entry_add(struct mlxsw_sp *mlxsw_sp,
 	return mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
 }
 
-static void mlxsw_sp_fib4_node_entry_del(struct mlxsw_sp *mlxsw_sp,
-					 struct mlxsw_sp_fib_entry *fib_entry)
+static void mlxsw_sp_fib_node_entry_del(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
 
@@ -2724,13 +2724,13 @@ static int mlxsw_sp_fib4_node_entry_link(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		return err;
 
-	err = mlxsw_sp_fib4_node_entry_add(mlxsw_sp, &fib4_entry->common);
+	err = mlxsw_sp_fib_node_entry_add(mlxsw_sp, &fib4_entry->common);
 	if (err)
-		goto err_fib4_node_entry_add;
+		goto err_fib_node_entry_add;
 
 	return 0;
 
-err_fib4_node_entry_add:
+err_fib_node_entry_add:
 	mlxsw_sp_fib4_node_list_remove(fib4_entry);
 	return err;
 }
@@ -2739,7 +2739,7 @@ static void
 mlxsw_sp_fib4_node_entry_unlink(struct mlxsw_sp *mlxsw_sp,
 				struct mlxsw_sp_fib4_entry *fib4_entry)
 {
-	mlxsw_sp_fib4_node_entry_del(mlxsw_sp, &fib4_entry->common);
+	mlxsw_sp_fib_node_entry_del(mlxsw_sp, &fib4_entry->common);
 	mlxsw_sp_fib4_node_list_remove(fib4_entry);
 }
 
-- 
2.9.3
