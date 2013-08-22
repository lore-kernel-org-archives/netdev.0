From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Thu, 22 Aug 2013 18:40:36 +0800
Message-ID: <1377168036-8359-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<stephen@networkplumber.org>
To: <b20596@freescale.com>, <b45643@freescale.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:12202 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752438Ab3HVKog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 06:44:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the current BD is the first BD, the previous BD entry
must be the last BD, not "bdp - 1".

Add BD entry check to get the previous BD entry correctly.

Signed-off-by: Fugang Duan  <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4ea1555..4349a9e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -380,7 +380,10 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		}
 	}
 
-	bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
+	if (bdp == fep->tx_bd_base)
+		bdp_pre = bdp + TX_RING_SIZE - 1;
+	else
+		bdp_pre = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
 	if ((id_entry->driver_data & FEC_QUIRK_ERR006358) &&
 	    !(bdp_pre->cbd_sc & BD_ENET_TX_READY)) {
 		fep->delay_work.trig_tx = true;
-- 
1.7.1
