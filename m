From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 03/10] net/mlx5e: Changed naming convention of tx queues in ethtool stats
Date: Sun, 28 Feb 2016 17:09:04 +0200
Message-ID: <1456672151-11749-4-git-send-email-saeedm@mellanox.com>
References: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59744 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757720AbcB1PJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 10:09:48 -0500
In-Reply-To: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Instead of the pair (channel, tc), we now use a single number that
goes over all tx queues of a TC, for all TCs.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index e9760f8..577b4b1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -211,13 +211,14 @@ static void mlx5e_get_strings(struct net_device *dev,
 				sprintf(data + (idx++) * ETH_GSTRING_LEN,
 					"rx%d_%s", i, rq_stats_strings[j]);
 
-		for (i = 0; i < priv->params.num_channels; i++)
-			for (tc = 0; tc < priv->params.num_tc; tc++)
+		for (tc = 0; tc < priv->params.num_tc; tc++)
+			for (i = 0; i < priv->params.num_channels; i++)
 				for (j = 0; j < NUM_SQ_STATS; j++)
 					sprintf(data +
-						(idx++) * ETH_GSTRING_LEN,
-						"tx%d_%d_%s", i, tc,
-						sq_stats_strings[j]);
+					      (idx++) * ETH_GSTRING_LEN,
+					      "tx%d_%s",
+					      priv->channeltc_to_txq_map[i][tc],
+					      sq_stats_strings[j]);
 		break;
 	}
 }
@@ -249,8 +250,8 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 						&priv->state) ? 0 :
 				       ((u64 *)&priv->channel[i]->rq.stats)[j];
 
-	for (i = 0; i < priv->params.num_channels; i++)
-		for (tc = 0; tc < priv->params.num_tc; tc++)
+	for (tc = 0; tc < priv->params.num_tc; tc++)
+		for (i = 0; i < priv->params.num_channels; i++)
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				data[idx++] = !test_bit(MLX5E_STATE_OPENED,
 							&priv->state) ? 0 :
-- 
1.7.1
