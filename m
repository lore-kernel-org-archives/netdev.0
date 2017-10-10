From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_en: Limit the number of RX rings
Date: Tue, 10 Oct 2017 12:28:34 +0300
Message-ID: <1507627715-25487-3-git-send-email-tariqt@mellanox.com>
References: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Inbar Karmy <inbark@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48108 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755670AbdJJJ2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 05:28:52 -0400
In-Reply-To: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Limit the number of RX rings by the number of cores
in the system.

Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index e9432bc1c1bc..bf1f04164885 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1742,12 +1742,17 @@ static int mlx4_en_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return err;
 }
 
+static int mlx4_en_get_max_num_rx_rings(struct net_device *dev)
+{
+	return min_t(int, num_online_cpus(), MAX_RX_RINGS);
+}
+
 static void mlx4_en_get_channels(struct net_device *dev,
 				 struct ethtool_channels *channel)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-	channel->max_rx = MAX_RX_RINGS;
+	channel->max_rx = mlx4_en_get_max_num_rx_rings(dev);
 	channel->max_tx = priv->mdev->profile.max_num_tx_rings_p_up;
 
 	channel->rx_count = priv->rx_ring_num;
-- 
1.8.3.1
