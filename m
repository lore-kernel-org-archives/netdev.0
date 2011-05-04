From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4_en: Setting RSS hash result to skb->rxhash field
Date: Wed, 4 May 2011 16:37:51 +0300
Message-ID: <4DC156AF.4050807@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45872 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750748Ab1EDNhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 09:37:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_rx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 62dd21b..bb4d66a 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -610,6 +610,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					gro_skb->data_len = length;
 					gro_skb->truesize += length;
 					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
+					gro_skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid) << 24;
+					skb_record_rx_queue(gro_skb, cq->ring);
 
 					if (priv->vlgrp && (cqe->vlan_my_qpn &
 							    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)))
@@ -643,6 +645,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			goto next;
 		}
 
+		skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid) << 24;
 		skb->ip_summed = ip_summed;
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
-- 
1.6.0.2



