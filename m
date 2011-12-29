From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [FIX PATCH net] mlx4_en: nullify cq->vector field when closing completion
 queue
Date: Thu, 29 Dec 2011 17:49:58 +0200
Message-ID: <4EFC8C26.3060006@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:57215 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752113Ab1L2Pz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 10:55:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Caused loss of connectivity when changing ring size.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 227997d..5829e0b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -147,6 +147,7 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
 	if (priv->mdev->dev->caps.comp_pool && cq->vector)
 		mlx4_release_eq(priv->mdev->dev, cq->vector);
+	cq->vector = 0;
 	cq->buf_size = 0;
 	cq->buf = NULL;
 }
-- 
1.5.4.3
