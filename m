From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 08/10] ftgmac100: Add missing barrier in ftgmac100_rx_packet()
Date: Thu,  6 Apr 2017 11:02:50 +1000
Message-ID: <20170406010252.29208-9-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37935 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756444AbdDFBDa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:30 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 86bda0a..594af30 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -442,6 +442,9 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	if (!ftgmac100_rxdes_packet_ready(rxdes))
 		return false;
 
+	/* Order subsequent reads with the test for the ready bit */
+	dma_rmb();
+
 	/* We don't cope with fragmented RX packets */
 	if (unlikely(!ftgmac100_rxdes_first_segment(rxdes) ||
 		     !ftgmac100_rxdes_last_segment(rxdes)))
-- 
2.9.3
