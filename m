From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V1 1/3] net/mlx4_en: Set correct port parameters during device initialization
Date: Mon, 25 Jun 2012 13:24:11 +0300
Message-ID: <1340619853-29804-2-git-send-email-yevgenyp@mellanox.co.il>
References: <1340619853-29804-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:47629 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756260Ab2FYNYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 09:24:22 -0400
In-Reply-To: <1340619853-29804-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set valid port parameters: MTU and flow control configuration when
configuring the port during HW device initialization,
prior to the net device open() being called.
Using  invalid parameters (such as all zeros)
could lead to bad firmware behavior.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 926d8aa..a80280e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1204,9 +1204,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
 
 	/* Configure port */
+	mlx4_en_calc_rx_buf(dev);
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
-				    MLX4_EN_MIN_MTU,
-				    0, 0, 0, 0);
+				    priv->rx_skb_size + ETH_FCS_LEN,
+				    prof->tx_pause, prof->tx_ppp,
+				    prof->rx_pause, prof->rx_ppp);
 	if (err) {
 		en_err(priv, "Failed setting port general configurations "
 		       "for port %d, with error %d\n", priv->port, err);
-- 
1.7.1
