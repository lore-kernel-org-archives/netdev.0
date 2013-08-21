From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 1/5] net/mlx4_en: Coding style cleanup in mlx4_en_dcbnl_ieee_setpfc()
Date: Wed, 21 Aug 2013 10:08:55 +0300
Message-ID: <1377068939-17561-2-git-send-email-amirv@mellanox.com>
References: <1377068939-17561-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45127 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752461Ab3HUHJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 03:09:12 -0400
In-Reply-To: <1377068939-17561-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some coding style issues in this function.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 9d4a1ea..f71fba9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -160,6 +160,7 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 		struct ieee_pfc *pfc)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_port_profile *prof = priv->prof;
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;
 
@@ -169,15 +170,17 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 			pfc->mbc,
 			pfc->delay);
 
-	priv->prof->rx_pause = priv->prof->tx_pause = !!pfc->pfc_en;
-	priv->prof->rx_ppp = priv->prof->tx_ppp = pfc->pfc_en;
+	prof->rx_pause = !!pfc->pfc_en;
+	prof->tx_pause = !!pfc->pfc_en;
+	prof->rx_ppp = pfc->pfc_en;
+	prof->tx_ppp = pfc->pfc_en;
 
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
 				    priv->rx_skb_size + ETH_FCS_LEN,
-				    priv->prof->tx_pause,
-				    priv->prof->tx_ppp,
-				    priv->prof->rx_pause,
-				    priv->prof->rx_ppp);
+				    prof->tx_pause,
+				    prof->tx_ppp,
+				    prof->rx_pause,
+				    prof->rx_ppp);
 	if (err)
 		en_err(priv, "Failed setting pause params\n");
 
-- 
1.8.3.4
