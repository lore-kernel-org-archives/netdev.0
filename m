From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 7/9 V2] mlx4_en: Always allocate RX ring for each interrupt
 vector
Date: Mon, 29 Dec 2008 11:57:02 +0200
Message-ID: <49589EEE.9030602@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:58524 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753817AbYL2J6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 04:58:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed module parameter specifying number of RX rings

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c   |   12 ++++--------
 drivers/net/mlx4/en_params.c |    5 -----
 2 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 34f3a19..eda72dd 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -169,14 +169,10 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
 		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
 			  mdev->profile.prof[i].tx_ring_num, i);
-		if (!mdev->profile.prof[i].rx_ring_num) {
-			mdev->profile.prof[i].rx_ring_num =
-				min_t(int, dev->caps.num_comp_vectors, MAX_RX_RINGS);
-			mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
-				  mdev->profile.prof[i].rx_ring_num, i);
-		} else
-			mlx4_info(mdev, "Using %d rx rings for port:%d\n",
-				  mdev->profile.prof[i].rx_ring_num, i);
+		mdev->profile.prof[i].rx_ring_num =
+			min_t(int, dev->caps.num_comp_vectors, MAX_RX_RINGS);
+		mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
+			  mdev->profile.prof[i].rx_ring_num, i);
 	}

 	/* Create our own workqueue for reset/multicast tasks
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index 047b37f..6483ae9 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -65,9 +65,6 @@ MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
 			   " Per priority bit mask");

-MLX4_EN_PARM_INT(rx_ring_num1, 0, "Number or Rx rings for port 1 (0 = #cores)");
-MLX4_EN_PARM_INT(rx_ring_num2, 0, "Number or Rx rings for port 2 (0 = #cores)");
-
 MLX4_EN_PARM_INT(tx_ring_size1, MLX4_EN_AUTO_CONF, "Tx ring size for port 1");
 MLX4_EN_PARM_INT(tx_ring_size2, MLX4_EN_AUTO_CONF, "Tx ring size for port 2");
 MLX4_EN_PARM_INT(rx_ring_size1, MLX4_EN_AUTO_CONF, "Rx ring size for port 1");
@@ -95,8 +92,6 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[1].tx_ring_num = 1;
 		params->prof[2].tx_ring_num = 1;
 	}
-	params->prof[1].rx_ring_num = min_t(int, rx_ring_num1, MAX_RX_RINGS);
-	params->prof[2].rx_ring_num = min_t(int, rx_ring_num2, MAX_RX_RINGS);

 	if (tx_ring_size1 == MLX4_EN_AUTO_CONF)
 		tx_ring_size1 = MLX4_EN_DEF_TX_RING_SIZE;
-- 
1.5.4

