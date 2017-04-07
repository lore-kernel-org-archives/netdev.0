From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 05/12] ftgmac100: Pad small frames properly
Date: Fri,  7 Apr 2017 13:30:58 +1000
Message-ID: <20170407033105.29558-6-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39165 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753805AbdDGDbq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:46 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than just transmitting garbage past the end of the small
packet.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 6c71726..3f2172f 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -636,6 +636,13 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	struct ftgmac100_txdes *txdes;
 	dma_addr_t map;
 
+	/* The HW doesn't pad small frames */
+	if (skb_padto(skb, ETH_ZLEN) < 0) {
+		netdev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
+	/* Reject oversize packets */
 	if (unlikely(skb->len > MAX_PKT_SIZE)) {
 		if (net_ratelimit())
 			netdev_dbg(netdev, "tx packet too big\n");
-- 
2.9.3
