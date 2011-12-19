From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 3/5] mlx4_en: nullify cached multicast address list
 after cleanup
Date: Mon, 19 Dec 2011 16:02:58 +0200
Message-ID: <4EEF4412.8040806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:48039 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750987Ab1LSQRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 11:17:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Guller <alexg@mellanox.com>

Solves an issue where we tried to free the same page twice after
the port has been opened and closed.

Signed-off-by: Alexander Guller <alexg@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 1db6fea..72fa807 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -151,6 +151,7 @@ static void mlx4_en_clear_list(struct net_device *dev)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
 	kfree(priv->mc_addrs);
+	priv->mc_addrs = NULL;
 	priv->mc_addrs_cnt = 0;
 }
 
@@ -170,6 +171,7 @@ static void mlx4_en_cache_mclist(struct net_device *dev)
 	i = 0;
 	netdev_for_each_mc_addr(ha, dev)
 		memcpy(mc_addrs + i++ * ETH_ALEN, ha->addr, ETH_ALEN);
+	mlx4_en_clear_list(dev);
 	priv->mc_addrs = mc_addrs;
 	priv->mc_addrs_cnt = mc_addrs_cnt;
 }
-- 
1.7.7
