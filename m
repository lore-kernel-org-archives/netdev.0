From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/5] net/mlx5: Fix create autogroup prev initializer
Date: Fri, 10 Mar 2017 14:33:01 +0200
Message-ID: <20170310123305.2185-2-saeedm@mellanox.com>
References: <20170310123305.2185-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38673 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934094AbdCJMdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:33:23 -0500
In-Reply-To: <20170310123305.2185-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

The autogroups list is a list of non overlapping group boundaries
sorted by their start index. If the autogroups list wasn't empty
and an empty group slot was found at the start of the list,
the new group was added to the end of the list instead of the
beginning, as the prev initializer was incorrect.
When this was repeated, it caused multiple groups to have
overlapping boundaries.

Fixed that by correctly initializing the prev pointer to the
start of the list.

Fixes: eccec8da3b4e ('net/mlx5: Keep autogroups list ordered')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Mark Bloch <markb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 2478516a61e2..ded27bb9a3b6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1136,7 +1136,7 @@ static struct mlx5_flow_group *create_autogroup(struct mlx5_flow_table *ft,
 						u32 *match_criteria)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
-	struct list_head *prev = ft->node.children.prev;
+	struct list_head *prev = &ft->node.children;
 	unsigned int candidate_index = 0;
 	struct mlx5_flow_group *fg;
 	void *match_criteria_addr;
-- 
2.11.0
