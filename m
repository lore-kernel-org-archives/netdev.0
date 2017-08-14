From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] mlxsw: spectrum_router: Return void from deletion functions
Date: Mon, 14 Aug 2017 10:54:03 +0200
Message-ID: <20170814085405.1452-2-jiri@resnulli.us>
References: <20170814085405.1452-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34235 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752558AbdHNIyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 04:54:10 -0400
Received: by mail-wr0-f196.google.com with SMTP id x43so369786wrb.1
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 01:54:09 -0700 (PDT)
In-Reply-To: <20170814085405.1452-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

There is no point in returning a value from function whose return value
is never checked.

Even if the return value was checked, there wouldn't be anything to do
about it, as these functions are either called from error or deletion
paths.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 93b6da8..220e7e7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -505,15 +505,15 @@ static int mlxsw_sp_lpm_tree_alloc(struct mlxsw_sp *mlxsw_sp,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
 }
 
-static int mlxsw_sp_lpm_tree_free(struct mlxsw_sp *mlxsw_sp,
-				  struct mlxsw_sp_lpm_tree *lpm_tree)
+static void mlxsw_sp_lpm_tree_free(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_lpm_tree *lpm_tree)
 {
 	char ralta_pl[MLXSW_REG_RALTA_LEN];
 
 	mlxsw_reg_ralta_pack(ralta_pl, false,
 			     (enum mlxsw_reg_ralxx_protocol) lpm_tree->proto,
 			     lpm_tree->id);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
 }
 
 static int
@@ -569,10 +569,10 @@ mlxsw_sp_lpm_tree_create(struct mlxsw_sp *mlxsw_sp,
 	return ERR_PTR(err);
 }
 
-static int mlxsw_sp_lpm_tree_destroy(struct mlxsw_sp *mlxsw_sp,
-				     struct mlxsw_sp_lpm_tree *lpm_tree)
+static void mlxsw_sp_lpm_tree_destroy(struct mlxsw_sp *mlxsw_sp,
+				      struct mlxsw_sp_lpm_tree *lpm_tree)
 {
-	return mlxsw_sp_lpm_tree_free(mlxsw_sp, lpm_tree);
+	mlxsw_sp_lpm_tree_free(mlxsw_sp, lpm_tree);
 }
 
 static struct mlxsw_sp_lpm_tree *
@@ -601,12 +601,11 @@ mlxsw_sp_lpm_tree_get(struct mlxsw_sp *mlxsw_sp,
 	return lpm_tree;
 }
 
-static int mlxsw_sp_lpm_tree_put(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_lpm_tree *lpm_tree)
+static void mlxsw_sp_lpm_tree_put(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_lpm_tree *lpm_tree)
 {
 	if (--lpm_tree->ref_count == 0)
-		return mlxsw_sp_lpm_tree_destroy(mlxsw_sp, lpm_tree);
-	return 0;
+		mlxsw_sp_lpm_tree_destroy(mlxsw_sp, lpm_tree);
 }
 
 #define MLXSW_SP_LPM_TREE_MIN 1 /* tree 0 is reserved */
-- 
2.9.3
