From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 1/2 net-next] net: stmmac: fix RX routing function name
Date: Thu,  8 Jun 2017 19:02:51 +0100
Message-ID: <014297b3b5a1654eda19f099082d04b79a98b16a.1496944749.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:52928 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdFHSC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:02:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the RX packet routing function name in dwmac4_core.
It also calls the correct dwmac4_core callback for the routing
configuration purpose.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index f233bf8..0df038f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -111,7 +111,7 @@ static void dwmac4_tx_queue_priority(struct mac_device_info *hw,
 	writel(value, ioaddr + base_register);
 }
 
-static void dwmac4_tx_queue_routing(struct mac_device_info *hw,
+static void dwmac4_rx_queue_routing(struct mac_device_info *hw,
 				    u8 packet, u32 queue)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -676,7 +676,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.rx_queue_prio = dwmac4_rx_queue_priority,
 	.tx_queue_prio = dwmac4_tx_queue_priority,
-	.rx_queue_routing = dwmac4_tx_queue_routing,
+	.rx_queue_routing = dwmac4_rx_queue_routing,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
@@ -707,7 +707,7 @@ static const struct stmmac_ops dwmac410_ops = {
 	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.rx_queue_prio = dwmac4_rx_queue_priority,
 	.tx_queue_prio = dwmac4_tx_queue_priority,
-	.rx_queue_routing = dwmac4_tx_queue_routing,
+	.rx_queue_routing = dwmac4_rx_queue_routing,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f446f36..9ca3a2d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2353,7 +2353,7 @@ static void stmmac_mac_config_rx_queues_routing(struct stmmac_priv *priv)
 			continue;
 
 		packet = priv->plat->rx_queues_cfg[queue].pkt_route;
-		priv->hw->mac->rx_queue_prio(priv->hw, packet, queue);
+		priv->hw->mac->rx_queue_routing(priv->hw, packet, queue);
 	}
 }
 
-- 
2.9.3
