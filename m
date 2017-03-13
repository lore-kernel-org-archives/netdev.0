From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 10/11] net: stmmac: tso init prepared for multiple queues
Date: Mon, 13 Mar 2017 16:12:41 +0000
Message-ID: <d24b08e07372ec506b93a0c3eb7c7035903a5fad.1489419357.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:33712 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754081AbdCMQNK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:13:10 -0400
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures TSO for all available tx queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 44db2e3..7f46493 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1965,6 +1965,8 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	u32 rx_cnt = priv->plat->rx_queues_to_use;
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
+	u32 chan;
 	int ret;
 
 	/* DMA initialization and SW reset */
@@ -2048,8 +2050,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	stmmac_set_rings_length(priv);
 
 	/* Enable TSO */
-	if (priv->tso)
-		priv->hw->dma->enable_tso(priv->ioaddr, 1, STMMAC_CHAN0);
+	if (priv->tso) {
+		for (chan = 0; chan < tx_cnt; chan++)
+			priv->hw->dma->enable_tso(priv->ioaddr, 1, chan);
+	}
 
 	return 0;
 }
-- 
2.9.3
