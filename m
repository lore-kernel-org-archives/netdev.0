From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/3] net/mlx4_en: Remove unnecessary checks when setting num channels
Date: Tue, 17 Jan 2017 19:19:18 +0200
Message-ID: <1484673559-21687-3-git-send-email-tariqt@mellanox.com>
References: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59494 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751145AbdAQR0o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:26:44 -0500
In-Reply-To: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Boundaries checks for the number of RX, TX, other and combined channels
should be checked by the caller and not in the driver.

In addition, remove wrong memset on get channels as it overrides the cmd
field in the requester struct.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index d9c9f86a30df..d5a9372ed84d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1732,8 +1732,6 @@ static void mlx4_en_get_channels(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-	memset(channel, 0, sizeof(*channel));
-
 	channel->max_rx = MAX_RX_RINGS;
 	channel->max_tx = MLX4_EN_MAX_TX_RING_P_UP;
 
@@ -1752,10 +1750,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	int xdp_count;
 	int err = 0;
 
-	if (channel->other_count || channel->combined_count ||
-	    channel->tx_count > MLX4_EN_MAX_TX_RING_P_UP ||
-	    channel->rx_count > MAX_RX_RINGS ||
-	    !channel->tx_count || !channel->rx_count)
+	if (!channel->tx_count || !channel->rx_count)
 		return -EINVAL;
 
 	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
-- 
1.8.3.1
