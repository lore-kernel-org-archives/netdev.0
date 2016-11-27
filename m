From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 08/10] net/mlx4_core: Get num_tc using netdev_get_num_tc
Date: Sun, 27 Nov 2016 17:51:15 +0200
Message-ID: <1480261877-19720-9-git-send-email-tariqt@mellanox.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Alaa Hleihel <alaa@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50464 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753154AbcK0Pvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:39 -0500
In-Reply-To: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alaa Hleihel <alaa@mellanox.com>

Avoid reading num_tc directly from struct net_device, but use
the helper function netdev_get_num_tc.

Fixes: bc6a4744b827 ("net/mlx4_en: num cores tx rings for every UP")
Fixes: f5b6345ba8da ("net/mlx4_en: User prio mapping gets corrupted when changing number of channels")
Signed-off-by: Alaa Hleihel <alaa@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 7e6d0425394d..9848302ace84 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1791,7 +1791,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num[TX]);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
-	if (dev->num_tc)
+	if (netdev_get_num_tc(dev))
 		mlx4_en_setup_tc(dev, MLX4_EN_NUM_UP);
 
 	en_warn(priv, "Using %d TX rings\n", priv->tx_ring_num[TX]);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 4b597dca5c52..abe1c5994b73 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -710,7 +710,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 	u16 rings_p_up = priv->num_tx_rings_p_up;
 	u8 up = 0;
 
-	if (dev->num_tc)
+	if (netdev_get_num_tc(dev))
 		return skb_tx_hash(dev, skb);
 
 	if (skb_vlan_tag_present(skb))
-- 
1.8.3.1
