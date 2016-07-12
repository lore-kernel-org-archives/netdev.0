From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/2] net/mlx5e: Fix TX Timeout to detect queues stuck on BQL
Date: Wed, 13 Jul 2016 00:06:59 +0300
Message-ID: <1468357620-27831-2-git-send-email-saeedm@mellanox.com>
References: <1468357620-27831-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40535 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750770AbcGLVHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 17:07:37 -0400
In-Reply-To: <1468357620-27831-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Change netif_tx_queue_stopped to netif_xmit_stopped.  This will show
when queues are stopped due to byte queue limits.

Fixes: 3947ca185999 ('net/mlx5e: Implement ndo_tx_timeout callback')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7a0dca2..0cebc7e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2656,7 +2656,7 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 	for (i = 0; i < priv->params.num_channels * priv->params.num_tc; i++) {
 		struct mlx5e_sq *sq = priv->txq_to_sq_map[i];
 
-		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)))
+		if (!netif_xmit_stopped(netdev_get_tx_queue(dev, i)))
 			continue;
 		sched_work = true;
 		set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);
-- 
2.8.0
