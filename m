From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: mlx4_en: Fix loss of promiscuity
Date: Sun, 27 Mar 2011 19:01:26 +0800
Message-ID: <20110327110126.GA25595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:38655 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab1C0LBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 07:01:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

mlx4_en: Fix loss of promiscuity

The mlx4_en driver uses the combination stop_port/start_port
in a number of places.  Unfortunately that causes any promiscuous
mode settings on the hardware to be lost.

This patch fixes that problem.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 5762ebd..4f158ba 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -742,6 +742,9 @@ int mlx4_en_start_port(struct net_device *dev)
 				  0, MLX4_PROT_ETH))
 		mlx4_warn(mdev, "Failed Attaching Broadcast\n");
 
+	/* Must redo promiscuous mode setup. */
+	priv->flags &= ~(MLX4_EN_FLAG_PROMISC | MLX4_EN_FLAG_MC_PROMISC);
+
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->mcast_task);
 
Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
