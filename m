From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 1/3] net: stmmac: Always enable MAC RX queues
Date: Tue, 21 Mar 2017 16:12:09 +0100
Message-ID: <20170321151211.31841-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        LABBE Corentin <clabbe.montjoie@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

The MAC RX queues always need to be enabled in order to receive network
packets. Remove the condition that this only needs to be done for multi-
queue configurations.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d3a21519e4c0..298956032098 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1943,7 +1943,7 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 		stmmac_rx_queue_dma_chan_map(priv);
 
 	/* Enable MAC RX Queues */
-	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
+	if (priv->hw->mac->rx_queue_enable)
 		stmmac_mac_enable_rx_queues(priv);
 
 	/* Set the HW DMA mode and the COE */
-- 
2.12.0
