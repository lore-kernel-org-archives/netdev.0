From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 6/7] net/mlx5e: Fix number of PFC counters reported to ethtool
Date: Mon, 27 Jun 2016 12:08:37 +0300
Message-ID: <1467018518-11630-7-git-send-email-saeedm@mellanox.com>
References: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53213 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751888AbcF0JQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:16:16 -0400
In-Reply-To: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Number of PFC counters used to count only number of priorities with PFC
enabled, but each priority has more than one counter, hence the need to
multiply it by the number of PFC counters per priority.

Fixes: cf678570d5a1 ('net/mlx5e: Add per priority group to PPort counters')
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index fc7dcc0..c709d41 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -184,7 +184,9 @@ static unsigned long mlx5e_query_pfc_combined(struct mlx5e_priv *priv)
 #define MLX5E_NUM_SQ_STATS(priv) \
 	(NUM_SQ_STATS * priv->params.num_channels * priv->params.num_tc * \
 	 test_bit(MLX5E_STATE_OPENED, &priv->state))
-#define MLX5E_NUM_PFC_COUNTERS(priv) hweight8(mlx5e_query_pfc_combined(priv))
+#define MLX5E_NUM_PFC_COUNTERS(priv) \
+	(hweight8(mlx5e_query_pfc_combined(priv)) * \
+	 NUM_PPORT_PER_PRIO_PFC_COUNTERS)
 
 static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 {
-- 
2.8.0
