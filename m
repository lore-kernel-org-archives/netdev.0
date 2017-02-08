From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/15] mlxsw: spectrum_router: Remove FIB info from FIB entry struct
Date: Wed,  8 Feb 2017 11:16:34 +0100
Message-ID: <1486549002-2056-8-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34695 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753307AbdBHKQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:52 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so32407362wmi.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:52 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

After the previous changes, the FIB info is embedded in every nexthop
group struct, which in turn is embedded in every FIB entry struct.

We can therefore safely remove the FIB info from the entry struct. This
has the added advantage of making the router-related structs more
generic and suitable for use with IPv6 offloads.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 8a72a1b..74839f7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -128,7 +128,6 @@ struct mlxsw_sp_fib_entry {
 	enum mlxsw_sp_fib_entry_type type;
 	unsigned int ref_count;
 	struct mlxsw_sp_vr *vr;
-	struct fib_info *fi;
 	struct list_head nexthop_group_node;
 	struct mlxsw_sp_nexthop_group *nh_group;
 };
@@ -1755,7 +1754,7 @@ mlxsw_sp_router_fib4_entry_fini(struct mlxsw_sp *mlxsw_sp,
 				struct mlxsw_sp_fib_entry *fib_entry)
 {
 	if (fib_entry->type != MLXSW_SP_FIB_ENTRY_TYPE_TRAP)
-		fib_info_offload_dec(fib_entry->fi);
+		fib_info_offload_dec(fib_entry->nh_group->key.fi);
 }
 
 static struct mlxsw_sp_fib_entry *
@@ -1788,7 +1787,6 @@ mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
 		goto err_fib_entry_create;
 	}
 	fib_entry->vr = vr;
-	fib_entry->fi = fi;
 	fib_entry->ref_count = 1;
 
 	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fen_info, fib_entry);
-- 
2.7.4
