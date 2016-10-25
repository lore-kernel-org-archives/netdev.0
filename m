From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 05/12] net/mlx5: Correctly initialize last use of flow counters
Date: Tue, 25 Oct 2016 18:36:28 +0300
Message-ID: <1477409795-28807-6-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40904 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754872AbcJYPiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:20 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

Currently, last use timestamp is initialized to zero.
This is not the expected value by higher layers such as
when we do TC action offloading. To fix that, set it to
the current time, e.g when the counter/rule is offloaded.
This is the same behaviour of non-offloaded TC actions.

Fixes: 43a335e055bb ('mlx5_core: Flow counters infrastructure')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index 3a9195b..3b026c1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -218,6 +218,7 @@ struct mlx5_fc *mlx5_fc_create(struct mlx5_core_dev *dev, bool aging)
 		goto err_out;
 
 	if (aging) {
+		counter->cache.lastuse = jiffies;
 		counter->aging = true;
 
 		spin_lock(&fc_stats->addlist_lock);
-- 
2.7.4
