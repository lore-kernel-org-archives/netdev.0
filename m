From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx4_en: Disable global flow control when PFC enabled
Date: Mon, 19 Aug 2013 09:42:20 +0300
Message-ID: <1376894542-27854-2-git-send-email-amirv@mellanox.com>
References: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34500 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750864Ab3HSGmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:42:42 -0400
In-Reply-To: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Fix a bug when FC and PFC are enabled/disabled at the same time.
According to ConnectX-3 Programmer Manual these two features are mutial
exclusive.  So make sure when enabling PFC to turn off global FC and
vise versa.  Otherwise it hurts the performance.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 9d4a1ea..fcef764 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -169,7 +169,8 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
 			pfc->mbc,
 			pfc->delay);
 
-	priv->prof->rx_pause = priv->prof->tx_pause = !!pfc->pfc_en;
+	priv->prof->rx_pause = !pfc->pfc_en;
+	priv->prof->tx_pause = !pfc->pfc_en;
 	priv->prof->rx_ppp = priv->prof->tx_ppp = pfc->pfc_en;
 
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
-- 
1.8.3.4
