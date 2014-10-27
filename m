From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 11/13] net/mlx4_en: Call napi_synchronize on stop_port
Date: Mon, 27 Oct 2014 11:37:45 +0200
Message-ID: <1414402667-8841-12-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40668 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752265AbaJ0JjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:39:04 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

This is instead of calling the actual implementation of
napi_synchronize, for better encapsulation.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c4450be..3c07a75 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1843,8 +1843,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 		}
 		local_bh_enable();
 
-		while (test_bit(NAPI_STATE_SCHED, &cq->napi.state))
-			msleep(1);
+		napi_synchronize(&cq->napi);
 		mlx4_en_deactivate_rx_ring(priv, priv->rx_ring[i]);
 		mlx4_en_deactivate_cq(priv, cq);
 
-- 
1.8.3.4
