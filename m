From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 06/12] can: ti_heccn: don't touch skb after netif_rx()
Date: Wed, 15 Jul 2015 09:09:43 +0200
Message-ID: <1436944189-26618-7-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Anant Gole <anantgole@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44208 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbbGOHJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 03:09:58 -0400
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not really
harmful as its a read access, except you turn on the proper debugging options
which catch a use after free.

Cc: Anant Gole <anantgole@ti.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/ti_hecc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index e95a9e1a889f..cf345cbfe819 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -747,9 +747,9 @@ static int ti_hecc_error(struct net_device *ndev, int int_status,
 		}
 	}
 
-	netif_rx(skb);
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+	netif_rx(skb);
 
 	return 0;
 }
-- 
2.1.4
