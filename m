From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH net v2 1/1] net: fec: Fix Transmitted bytes counter
Date: Fri, 28 Jun 2013 10:51:22 +0100
Message-ID: <1372413082-7983-1-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:44171 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab3F1Jvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 05:51:33 -0400
In-Reply-To: <Jim Baxter <jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx_bytes field was not being updated so the
network card statistics showed 0.0B transmitted.

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
Change from v1 to v2
Moved the tx_bytes incrementing to include all packets passed to the
network card.

 drivers/net/ethernet/freescale/fec_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d48099f..51493ce 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -332,6 +332,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	/* Save skb pointer */
 	fep->tx_skbuff[index] = skb;
+	ndev->stats.tx_bytes += skb->len;
 
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
-- 
1.7.10.4
