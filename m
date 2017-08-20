From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [V2 net-next 02/15] net/mlx5e: IPoIB, Fix driver name retrieved by ethtool
Date: Sun, 20 Aug 2017 16:49:03 +0300
Message-ID: <20170820134916.10222-3-saeedm@mellanox.com>
References: <20170820134916.10222-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Feras Daoud <ferasda@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44764 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750742AbdHTNtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 09:49:23 -0400
In-Reply-To: <20170820134916.10222-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feras Daoud <ferasda@mellanox.com>

Printing an enhanced IPoIB device information using
"ethtool -i DEVNAME", prints the low level driver name: mlx5_core.
This commit changes the name to mlx5_core [ib_ipoib], to include the
ipoib device driver infromation.

Fixes: 076b0936e5fb ("net/mlx5e: IPoIB, Add ethtool support")
Signed-off-by: Feras Daoud <ferasda@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
index eb04e97d8765..b080fabfe8de 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
@@ -39,6 +39,8 @@ static void mlx5i_get_drvinfo(struct net_device *dev,
 	struct mlx5e_priv *priv = mlx5i_epriv(dev);
 
 	mlx5e_ethtool_get_drvinfo(priv, drvinfo);
+	strlcpy(drvinfo->driver, DRIVER_NAME "[ib_ipoib]",
+		sizeof(drvinfo->driver));
 }
 
 static void mlx5i_get_strings(struct net_device *dev,
-- 
2.13.0
