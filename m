From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 06/12] net/mlx5: Release FTE lock in error flow
Date: Wed, 28 Dec 2016 14:58:36 +0200
Message-ID: <1482929922-32626-7-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32810 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751614AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Release the FTE lock when adding rule to the FTE has failed.

Fixes: 0fd758d6112f ('net/mlx5: Don't unlock fte while still using it')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Reviewed-by: Mark Bloch <markb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index a263d89..0ac7a2f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1263,6 +1263,7 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 	nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
 	handle = add_rule_fte(fte, fg, dest, dest_num, false);
 	if (IS_ERR(handle)) {
+		unlock_ref_node(&fte->node);
 		kfree(fte);
 		goto unlock_fg;
 	}
-- 
2.7.4
