From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/3] net/mlx5e: Remove unnecessary checks when setting num channels
Date: Tue, 17 Jan 2017 19:19:19 +0200
Message-ID: <1484673559-21687-4-git-send-email-tariqt@mellanox.com>
References: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59495 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751132AbdAQR0o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:26:44 -0500
In-Reply-To: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Boundaries checks for the number of RX and TX should be checked by the
caller and not in the driver.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 33a399a8b5d5..b1b9eb6ee135 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -554,16 +554,6 @@ static int mlx5e_set_channels(struct net_device *dev,
 			    __func__);
 		return -EINVAL;
 	}
-	if (ch->rx_count || ch->tx_count) {
-		netdev_info(dev, "%s: separate rx/tx count not supported\n",
-			    __func__);
-		return -EINVAL;
-	}
-	if (count > ncv) {
-		netdev_info(dev, "%s: count (%d) > max (%d)\n",
-			    __func__, count, ncv);
-		return -EINVAL;
-	}
 
 	if (priv->params.num_channels == count)
 		return 0;
-- 
1.8.3.1
