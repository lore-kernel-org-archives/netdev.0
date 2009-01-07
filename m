From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/2] mlx4_en: Returning real Max in get_ringparam
Date: Wed, 07 Jan 2009 17:04:31 +0200
Message-ID: <4964C47F.1090203@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:57473 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759402AbZAGPFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 10:05:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_params.c |    6 ++++--
 drivers/net/mlx4/mlx4_en.h   |    4 ++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index cfeef0f..c1bd040 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -399,8 +399,10 @@ static int mlx4_en_set_ringparam(struct net_device *dev,

 	rx_size = roundup_pow_of_two(param->rx_pending);
 	rx_size = max_t(u32, rx_size, MLX4_EN_MIN_RX_SIZE);
+	rx_size = min_t(u32, rx_size, MLX4_EN_MAX_RX_SIZE);
 	tx_size = roundup_pow_of_two(param->tx_pending);
 	tx_size = max_t(u32, tx_size, MLX4_EN_MIN_TX_SIZE);
+	tx_size = min_t(u32, tx_size, MLX4_EN_MAX_TX_SIZE);

 	if (rx_size == priv->prof->rx_ring_size &&
 	    tx_size == priv->prof->tx_ring_size)
@@ -440,8 +442,8 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 	struct mlx4_en_dev *mdev = priv->mdev;

 	memset(param, 0, sizeof(*param));
-	param->rx_max_pending = mdev->dev->caps.max_rq_sg;
-	param->tx_max_pending = mdev->dev->caps.max_sq_sg;
+	param->rx_max_pending = MLX4_EN_MAX_RX_SIZE;
+	param->tx_max_pending = MLX4_EN_MAX_TX_SIZE;
 	param->rx_pending = mdev->profile.prof[priv->port].rx_ring_size;
 	param->tx_pending = mdev->profile.prof[priv->port].tx_ring_size;
 }
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 08bf321..e9af32d 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -115,6 +115,10 @@ enum {
 };
 #define MLX4_EN_MAX_RX_FRAGS	4

+/* Maximum ring sizes */
+#define MLX4_EN_MAX_TX_SIZE	8192
+#define MLX4_EN_MAX_RX_SIZE	8192
+
 /* Minimum ring size for our page-allocation sceme to work */
 #define MLX4_EN_MIN_RX_SIZE	(MLX4_EN_ALLOC_SIZE / SMP_CACHE_BYTES)
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)
-- 
1.5.4

