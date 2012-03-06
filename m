From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 4/8] net/mlx4: fix sparse warnings on wrong type
 for RSS keys
Date: Tue, 6 Mar 2012 16:04:07 +0200
Message-ID: <4F561957.4030501@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:42305 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758612Ab2CFOE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:04:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

The keys used for the hardware RSS topelitz hash are of type __be32
where the values provided by the driver are from array of u32,
this triggered sparse warning on incorrect type in assignment as of different base types.
Since these values are picked randomly,
the fix is to transform the key to __be32 by executing cpu_to_be_32()

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c881712..9adbd53 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -910,7 +910,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
 	for (i = 0; i < 10; i++)
-		rss_context->rss_key[i] = rsskey[i];
+		rss_context->rss_key[i] = cpu_to_be32(rsskey[i]);
 
 	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
 			       &rss_map->indir_qp, &rss_map->indir_state);
-- 
1.7.7
