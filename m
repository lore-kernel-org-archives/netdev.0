From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 04/11] net: stmmac: prepare stmmac_tx_err for multiple queues
Date: Mon, 13 Mar 2017 16:12:35 +0000
Message-ID: <eaebf2be1a75b0850708f85be007a5dd98e75fc2.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:57374 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753087AbdCMQNM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:13:12 -0400
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares stmmac_err for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 58ad199..9b64f2e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1525,12 +1525,12 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv, u32 chan)
 /**
  * stmmac_tx_err - to manage the tx error
  * @priv: driver private structure
+ * @chan: channel index
  * Description: it cleans the descriptors and restarts the transmission
  * in case of transmission errors.
  */
-static void stmmac_tx_err(struct stmmac_priv *priv)
+static void stmmac_tx_err(struct stmmac_priv *priv, u32 chan)
 {
-	u32 chan = STMMAC_CHAN0;
 	int i;
 	netif_stop_queue(priv->dev);
 
@@ -1616,7 +1616,7 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 			priv->xstats.threshold = tc;
 		}
 	} else if (unlikely(status == tx_hard_error))
-		stmmac_tx_err(priv);
+		stmmac_tx_err(priv, chan);
 }
 
 /**
@@ -2944,9 +2944,10 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 static void stmmac_tx_timeout(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 chan = STMMAC_CHAN0;
 
 	/* Clear Tx resources and restart transmitting again */
-	stmmac_tx_err(priv);
+	stmmac_tx_err(priv, chan);
 }
 
 /**
-- 
2.9.3
