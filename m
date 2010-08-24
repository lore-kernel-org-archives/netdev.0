From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 02/14] mlx4_en: Setting actual RX ring size
Date: Tue, 24 Aug 2010 16:45:20 +0300
Message-ID: <4C73CCF0.1020903@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50027 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755151Ab0HXNpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:45:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring HW resources, the RX ring size that is passed should be the actual
size that depends on number of buffers that we succeeded to allocate.
The mask for ring size should also be configured accordingly

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 1ee4fd5..394da29 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -251,7 +251,6 @@ reduce_rings:
 			ring->prod--;
 			mlx4_en_free_rx_desc(priv, ring, ring->actual_size);
 		}
-		ring->size_mask = ring->actual_size - 1;
 	}
 
 	return 0;
@@ -389,6 +388,7 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
 		ring = &priv->rx_ring[ring_ind];
 
+		ring->size_mask = ring->actual_size - 1;
 		mlx4_en_update_rx_prod_db(ring);
 	}
 
@@ -816,7 +816,7 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
 	qp->event = mlx4_en_sqp_event;
 
 	memset(context, 0, sizeof *context);
-	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 0, 0,
+	mlx4_en_fill_qp_context(priv, ring->actual_size, ring->stride, 0, 0,
 				qpn, ring->cqn, context);
 	context->db_rec_addr = cpu_to_be64(ring->wqres.db.dma);
 
-- 
1.6.1.3


