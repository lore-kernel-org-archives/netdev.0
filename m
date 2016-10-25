From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum_router: Save requested prefix bitlist when creating tree
Date: Tue, 25 Oct 2016 11:25:56 +0200
Message-ID: <1477387557-5048-2-git-send-email-jiri@resnulli.us>
References: <1477387557-5048-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37169 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757228AbcJYJ0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 05:26:11 -0400
Received: by mail-wm0-f65.google.com with SMTP id 79so632129wmy.4
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 02:26:10 -0700 (PDT)
In-Reply-To: <1477387557-5048-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently, the prefix bitlist is not saved for LPM trees, causing the
compare to always fail which causes the tree to be destroyed and created
for every inserted and removed FIB entry. So fix this by saving
the bitlist as it should have been done from the very beginning.

Fixes: 53342023eed9 ("mlxsw: spectrum_router: Implement LPM trees management")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index f3d50d3..4cff4c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -320,6 +320,8 @@ mlxsw_sp_lpm_tree_create(struct mlxsw_sp *mlxsw_sp,
 						lpm_tree);
 	if (err)
 		goto err_left_struct_set;
+	memcpy(&lpm_tree->prefix_usage, prefix_usage,
+	       sizeof(lpm_tree->prefix_usage));
 	return lpm_tree;
 
 err_left_struct_set:
-- 
2.5.5
