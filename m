From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] spectrum: acl_tcam: Fix catchall prio value
Date: Tue,  7 Feb 2017 15:27:23 +0100
Message-ID: <1486477643-5920-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36714 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753829AbdBGO11 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:27:27 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so28680379wmd.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 06:27:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This fixes an issue reported by smatch:
mlxsw_sp_acl_tcam_chunk_create() warn: impossible condition '(priority == (-1)) => (0-u32max == u64max)'

Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 22a677661f56 ("mlxsw: spectrum: Introduce ACL core with simple TCAM implementation")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index a0a968e..1ec3dd0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -561,7 +561,7 @@ mlxsw_sp_acl_tcam_region_entry_remove(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptce2), ptce2_pl);
 }
 
-#define MLXSW_SP_ACL_TCAM_CATCHALL_PRIO (-1UL)
+#define MLXSW_SP_ACL_TCAM_CATCHALL_PRIO (-1U)
 
 static int
 mlxsw_sp_acl_tcam_region_catchall_add(struct mlxsw_sp *mlxsw_sp,
-- 
2.7.4
