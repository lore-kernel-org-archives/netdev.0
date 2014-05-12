From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/9] net/mlx4_en: User prio mapping gets corrupted when changing number of channels
Date: Mon, 12 May 2014 10:43:18 +0300
Message-ID: <1399880605-28772-3-git-send-email-amirv@mellanox.com>
References: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37711 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751848AbaELHnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 03:43:46 -0400
In-Reply-To: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

When using ethtool set_channels, mlx4_en_setup_tc is always called, even
when it was not configured. Fixed code to call mlx4_en_setup_tc() only if
needed.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c373604..a72d99f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1151,7 +1151,8 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
-	mlx4_en_setup_tc(dev, MLX4_EN_NUM_UP);
+	if (dev->num_tc)
+		mlx4_en_setup_tc(dev, MLX4_EN_NUM_UP);
 
 	en_warn(priv, "Using %d TX rings\n", priv->tx_ring_num);
 	en_warn(priv, "Using %d RX rings\n", priv->rx_ring_num);
-- 
1.8.3.4
