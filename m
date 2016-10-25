From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum_router: Compare only trees which are in use during tree get
Date: Tue, 25 Oct 2016 11:25:57 +0200
Message-ID: <1477387557-5048-3-git-send-email-jiri@resnulli.us>
References: <1477387557-5048-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38499 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757390AbcJYJ0C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 05:26:02 -0400
Received: by mail-wm0-f68.google.com with SMTP id h8so636577wmi.5
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 02:26:01 -0700 (PDT)
In-Reply-To: <1477387557-5048-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Only trees which are in use should be compared to requested prefix usage.

Fixes: 53342023eed9 ("mlxsw: spectrum_router: Implement LPM trees management")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 4cff4c0..4573da2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -345,7 +345,8 @@ mlxsw_sp_lpm_tree_get(struct mlxsw_sp *mlxsw_sp,
 
 	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
 		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
-		if (lpm_tree->proto == proto &&
+		if (lpm_tree->ref_count != 0 &&
+		    lpm_tree->proto == proto &&
 		    mlxsw_sp_prefix_usage_eq(&lpm_tree->prefix_usage,
 					     prefix_usage))
 			goto inc_ref_count;
-- 
2.5.5
