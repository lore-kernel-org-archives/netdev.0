From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 10/10] net/mlx4_en: Save slave ethtool stats command
Date: Thu, 27 Oct 2016 16:27:22 +0300
Message-ID: <1477574842-29688-11-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57543 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932748AbcJ0Ny1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:27 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following the previous patch, as an optimization, the slave will
not even bother sending the DUMP_ETH_STATS command over the
comm channel.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 314f54c8dbed..12c99a2655f2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1917,8 +1917,9 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int i;
 
-	if (mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 1))
-		en_dbg(HW, priv, "Failed dumping statistics\n");
+	if (!mlx4_is_slave(mdev->dev))
+		if (mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 1))
+			en_dbg(HW, priv, "Failed dumping statistics\n");
 
 	memset(&priv->pstats, 0, sizeof(priv->pstats));
 	memset(&priv->pkstats, 0, sizeof(priv->pkstats));
-- 
1.8.3.1
