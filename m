From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 04/12] net/mlx5: Fix autogroups groups num not decreasing
Date: Tue, 25 Oct 2016 18:36:27 +0300
Message-ID: <1477409795-28807-5-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40900 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754926AbcJYPiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:20 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

Autogroups groups num is increased when creating a new flow group,
but is never decreased.

Now decreasing it when deleting a flow group.

Fixes: f0d22d187473 ('net/mlx5_core: Introduce flow steering autogrouped flow table')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 17559c8..8969604 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -436,6 +436,9 @@ static void del_flow_group(struct fs_node *node)
 	fs_get_obj(ft, fg->node.parent);
 	dev = get_dev(&ft->node);
 
+	if (ft->autogroup.active)
+		ft->autogroup.num_groups--;
+
 	if (mlx5_cmd_destroy_flow_group(dev, ft, fg->id))
 		mlx5_core_warn(dev, "flow steering can't destroy fg %d of ft %d\n",
 			       fg->id, ft->id);
-- 
2.7.4
