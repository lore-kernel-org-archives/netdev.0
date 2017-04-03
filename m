From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next] net: stmmac: rx queue to dma channel mapping fix
Date: Mon,  3 Apr 2017 16:34:04 +0100
Message-ID: <4532d68ceefa4d0327275036698b3ec0e7b967c8.1491233596.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:47635 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdDCPeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 11:34:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In hardware configurations where multiple queues are active,
the rx queue needs to be mapped into a dma channel, even if
a single rx queue is used.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c1c6319..7cbda41 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2001,7 +2001,7 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 		stmmac_configure_cbs(priv);
 
 	/* Map RX MTL to DMA channels */
-	if (rx_queues_count > 1 && priv->hw->mac->map_mtl_to_dma)
+	if (priv->hw->mac->map_mtl_to_dma)
 		stmmac_rx_queue_dma_chan_map(priv);
 
 	/* Enable MAC RX Queues */
-- 
2.9.3
