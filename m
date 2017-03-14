From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 10/11] net: stmmac: tso init prepared for multiple queues
Date: Tue, 14 Mar 2017 10:24:32 +0000
Message-ID: <fab6df2757145ad051b3f1ced4bf96fbfb881780.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:45447 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdCNKZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:25:12 -0400
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures TSO for all available tx queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up the patch-set version

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 725fe3e..fccd3f7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1966,6 +1966,8 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	u32 rx_cnt = priv->plat->rx_queues_to_use;
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
+	u32 chan;
 	int ret;
 
 	/* DMA initialization and SW reset */
@@ -2049,8 +2051,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
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
