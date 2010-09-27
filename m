From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 11/17] mlx4_en: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:29:34 +0100
Message-ID: <1285612174.2263.309.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51979 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933309Ab0I0S3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:29:37 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mlx4/en_netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 411bda5..79478bd 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1025,7 +1025,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	 */
 	dev->netdev_ops = &mlx4_netdev_ops;
 	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
-	dev->real_num_tx_queues = MLX4_EN_NUM_TX_RINGS;
+	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
+	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

