From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 14/15] net/mlx5e: IPoIB, Support the flash device ethtool callback
Date: Fri, 23 Jun 2017 17:26:21 +0300
Message-ID: <20170623142622.16565-15-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54073 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754088AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

This callback further invokes the mlxfw module to flash the new
firmware file to the device.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
index bf686f0fde5d..eb04e97d8765 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
@@ -121,6 +121,14 @@ static int mlx5i_get_ts_info(struct net_device *netdev,
 	return mlx5e_ethtool_get_ts_info(priv, info);
 }
 
+static int mlx5i_flash_device(struct net_device *netdev,
+			      struct ethtool_flash *flash)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+
+	return mlx5e_ethtool_flash_device(priv, flash);
+}
+
 const struct ethtool_ops mlx5i_ethtool_ops = {
 	.get_drvinfo       = mlx5i_get_drvinfo,
 	.get_strings       = mlx5i_get_strings,
@@ -128,6 +136,7 @@ const struct ethtool_ops mlx5i_ethtool_ops = {
 	.get_ethtool_stats = mlx5i_get_ethtool_stats,
 	.get_ringparam     = mlx5i_get_ringparam,
 	.set_ringparam     = mlx5i_set_ringparam,
+	.flash_device      = mlx5i_flash_device,
 	.get_channels      = mlx5i_get_channels,
 	.set_channels      = mlx5i_set_channels,
 	.get_coalesce      = mlx5i_get_coalesce,
-- 
2.11.0
