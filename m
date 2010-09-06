From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/2] mlx4_en: Consider napi_get_frags() failure.
Date: Mon, 6 Sep 2010 11:20:11 +0300
Message-ID: <4C84A43B.5010605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>, <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39755 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752692Ab0IFIUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 04:20:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If failed to get skb frags using napi_get_frags(),
the packet is dropped.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_rx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index c4aad7f..570f250 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -591,6 +591,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				 * - not an IP fragment */
 				if (dev->features & NETIF_F_GRO) {
 					struct sk_buff *gro_skb = napi_get_frags(&cq->napi);
+					if (!gro_skb)
+						goto next;
 
 					nr = mlx4_en_complete_rx_desc(
 						priv, rx_desc,
-- 
1.6.1.3


