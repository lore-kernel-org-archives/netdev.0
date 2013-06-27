From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH net v1 1/1] net: fec: Fix Transmitted bytes counter
Date: Thu, 27 Jun 2013 19:25:08 +0100
Message-ID: <1372357508-23038-1-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:63875 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab3F0SZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 14:25:20 -0400
In-Reply-To: <Jim Baxter <jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx_bytes field was not being updated so the
network card statistics showed 0.0B transmitted.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ed6180e..05a5f76 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -738,6 +738,7 @@ fec_enet_tx(struct net_device *ndev)
 				ndev->stats.tx_carrier_errors++;
 		} else {
 			ndev->stats.tx_packets++;
+			ndev->stats.tx_bytes += bdp->cbd_datlen;
 		}
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) &&
-- 
1.7.10.4
