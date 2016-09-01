From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/6] mlxsw: spectrum_router: Fix fib entry update path
Date: Thu,  1 Sep 2016 10:37:41 +0200
Message-ID: <1472719065-3247-3-git-send-email-jiri@resnulli.us>
References: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34900 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753023AbcIAIhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 04:37:52 -0400
Received: by mail-wm0-f68.google.com with SMTP id c133so2651423wmd.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 01:37:52 -0700 (PDT)
In-Reply-To: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Originally, I expected that there would be needed to call update
operation in case RALUE record action is changed. However, that is not
needed since write operation takes care of that nicely. Remove prepared
construct and always call the write operation.

Fixes: 61c503f976b5 ("mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index ed61814..49f4e06 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -125,7 +125,6 @@ struct mlxsw_sp_fib_entry {
 	struct mlxsw_sp_fib_key key;
 	enum mlxsw_sp_fib_entry_type type;
 	unsigned int ref_count;
-	u8 added:1;
 	u16 rif; /* used for action local */
 	struct mlxsw_sp_vr *vr;
 	struct list_head nexthop_group_node;
@@ -1633,11 +1632,8 @@ static int mlxsw_sp_fib_entry_op(struct mlxsw_sp *mlxsw_sp,
 static int mlxsw_sp_fib_entry_update(struct mlxsw_sp *mlxsw_sp,
 				     struct mlxsw_sp_fib_entry *fib_entry)
 {
-	enum mlxsw_reg_ralue_op op;
-
-	op = !fib_entry->added ? MLXSW_REG_RALUE_OP_WRITE_WRITE :
-				 MLXSW_REG_RALUE_OP_WRITE_UPDATE;
-	return mlxsw_sp_fib_entry_op(mlxsw_sp, fib_entry, op);
+	return mlxsw_sp_fib_entry_op(mlxsw_sp, fib_entry,
+				     MLXSW_REG_RALUE_OP_WRITE_WRITE);
 }
 
 static int mlxsw_sp_fib_entry_del(struct mlxsw_sp *mlxsw_sp,
-- 
2.5.5
