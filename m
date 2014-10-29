From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: use napi_schedule_irqoff()
Date: Wed, 29 Oct 2014 16:54:45 -0700
Message-ID: <1414626885.631.102.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:65283 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482AbaJ2Xyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 19:54:43 -0400
Received: by mail-pd0-f175.google.com with SMTP id y13so3958167pdi.34
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 16:54:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mlx4_en_rx_irq() and mlx4_en_tx_irq() run from hard interrupt context.

They can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c8e75dab80553c876b195361456fb49587231055..c562c1468944f9ad4319e5faaf19bf9e66d15eaf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -878,8 +878,8 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_cq *cq = container_of(mcq, struct mlx4_en_cq, mcq);
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
-	if (priv->port_up)
-		napi_schedule(&cq->napi);
+	if (likely(priv->port_up))
+		napi_schedule_irqoff(&cq->napi);
 	else
 		mlx4_en_arm_cq(priv, cq);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 34c137878545fc672dad1a3d86e11c034c0ac368..5c4062921cdf46f1a7021a39705275c33ca4de77 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -479,8 +479,8 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_cq *cq = container_of(mcq, struct mlx4_en_cq, mcq);
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
-	if (priv->port_up)
-		napi_schedule(&cq->napi);
+	if (likely(priv->port_up))
+		napi_schedule_irqoff(&cq->napi);
 	else
 		mlx4_en_arm_cq(priv, cq);
 }
