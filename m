From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] net: stmmac: added default rx queue size in stmmac_dma_interrupt
Date: Mon, 13 Mar 2017 10:36:29 +0000
Message-ID: <a8cc3d88196f92c19e0740199826762a71bc48d7.1489401298.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:52785 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdCMKgf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 06:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the rx queue default size when dma interrupts are treated,
since dma op mode can be also set there.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 915636f..ec363e1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1455,6 +1455,9 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	int status;
 	int rxfifosz = priv->plat->rx_fifo_size;
 
+	if (rxfifosz == 0)
+		rxfifosz = priv->dma_cap.rx_fifo_size;
+
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely((status & handle_rx)) || (status & handle_tx)) {
 		if (likely(napi_schedule_prep(&priv->napi))) {
-- 
2.9.3
