From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 12/13] ftgmac100: Remove useless tests in interrupt handler
Date: Wed,  5 Apr 2017 12:28:52 +1000
Message-ID: <20170405022853.8238-13-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48217 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755122AbdDECaS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:30:18 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt is neither enabled nor registered when the interface
isn't running (regardless of whether we use nc-si or not) so the
test isn't useful.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 3adfb92..4fa138b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1047,14 +1047,9 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 	struct net_device *netdev = dev_id;
 	struct ftgmac100 *priv = netdev_priv(netdev);
 
-	/* When running in NCSI mode, the interface should be ready for
-	 * receiving or transmitting NCSI packets before it's opened.
-	 */
-	if (likely(priv->use_ncsi || netif_running(netdev))) {
-		/* Disable interrupts for polling */
-		iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
-		napi_schedule(&priv->napi);
-	}
+	/* Disable interrupts for polling */
+	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
+	napi_schedule(&priv->napi);
 
 	return IRQ_HANDLED;
 }
-- 
2.9.3
