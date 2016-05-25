From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/4] net/mlx4_en: clear some TX ring stats in mlx4_en_clear_stats()
Date: Wed, 25 May 2016 09:50:37 -0700
Message-ID: <1464195039-5098-3-git-send-email-edumazet@google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33486 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900AbcEYQuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 12:50:51 -0400
Received: by mail-pf0-f171.google.com with SMTP id b124so20234903pfb.0
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 09:50:51 -0700 (PDT)
In-Reply-To: <1464195039-5098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4_en_clear_stats() clears about everything but few TX ring
fields are missing :
- queue_stopped, wake_queue, tso_packets, xmit_more

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index cfd50206f7c3..bd637c4eff13 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1893,6 +1893,10 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 		priv->tx_ring[i]->packets = 0;
 		priv->tx_ring[i]->tx_csum = 0;
 		priv->tx_ring[i]->tx_dropped = 0;
+		priv->tx_ring[i]->queue_stopped = 0;
+		priv->tx_ring[i]->wake_queue = 0;
+		priv->tx_ring[i]->tso_packets = 0;
+		priv->tx_ring[i]->xmit_more = 0;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		priv->rx_ring[i]->bytes = 0;
-- 
2.8.0.rc3.226.g39d4020
