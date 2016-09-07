From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/5] net/mlx5e: Fix global PFC counters replication
Date: Wed,  7 Sep 2016 19:08:00 +0300
Message-ID: <1473264481-20392-5-git-send-email-saeedm@mellanox.com>
References: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58432 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752299AbcIGQIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:08:36 -0400
In-Reply-To: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Currently when reading global PFC statistics we left the counter
iterator out of the equation and we ended up reading the same counter
over and over again.

Instead of reading the counter at index 0 on every iteration we now read
the counter at index (i).

Fixes: e989d5a532ce ('net/mlx5e: Expose flow control counters to ethtool')
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 98e1a4a..7a346bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -331,7 +331,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 	if (mlx5e_query_global_pause_combined(priv)) {
 		for (i = 0; i < NUM_PPORT_PER_PRIO_PFC_COUNTERS; i++) {
 			data[idx++] = MLX5E_READ_CTR64_BE(&priv->stats.pport.per_prio_counters[0],
-							  pport_per_prio_pfc_stats_desc, 0);
+							  pport_per_prio_pfc_stats_desc, i);
 		}
 	}
 
-- 
2.7.4
