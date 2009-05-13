From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4_en: Fix not deleted napi structures
Date: Wed, 13 May 2009 14:47:22 +0300
Message-ID: <4A0AB34A.10100@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:44280 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750722AbZEMLqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 07:46:20 -0400
In-Reply-To: <49EC859C.700@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Napi structures are being created each time we open a port, but when
the port is closed the napi structure is only disabled but not removed.
This bug caused hang while removing the driver.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_cq.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/mlx4/en_cq.c
index 91f50de..a276125 100644
--- a/drivers/net/mlx4/en_cq.c
+++ b/drivers/net/mlx4/en_cq.c
@@ -125,8 +125,10 @@ void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)

 	if (cq->is_tx)
 		del_timer(&cq->timer);
-	else
+	else {
 		napi_disable(&cq->napi);
+		netif_napi_del(&cq->napi);
+	}

 	mlx4_cq_free(mdev->dev, &cq->mcq);
 }
-- 
1.6.0


