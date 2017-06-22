From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: stmmac: make some functions static
Date: Thu, 22 Jun 2017 17:17:29 +0100
Message-ID: <20170622161729.23602-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The functions dwmac4_dma_init_rx_chan, dwmac4_dma_init_tx_chan and
dwmac4_dma_init_channel do not need to be in global scope, so them
static.

Cleans up sparse warnings:
"symbol 'dwmac4_dma_init_rx_chan' was not declared. Should it be static?"
"symbol 'dwmac4_dma_init_tx_chan' was not declared. Should it be static?"
"symbol 'dwmac4_dma_init_channel' was not declared. Should it be static?"

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index eec8463057fd..e84831e1b63b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -71,9 +71,9 @@ static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 }
 
-void dwmac4_dma_init_rx_chan(void __iomem *ioaddr,
-			     struct stmmac_dma_cfg *dma_cfg,
-			     u32 dma_rx_phy, u32 chan)
+static void dwmac4_dma_init_rx_chan(void __iomem *ioaddr,
+				    struct stmmac_dma_cfg *dma_cfg,
+				    u32 dma_rx_phy, u32 chan)
 {
 	u32 value;
 	u32 rxpbl = dma_cfg->rxpbl ?: dma_cfg->pbl;
@@ -85,9 +85,9 @@ void dwmac4_dma_init_rx_chan(void __iomem *ioaddr,
 	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(chan));
 }
 
-void dwmac4_dma_init_tx_chan(void __iomem *ioaddr,
-			     struct stmmac_dma_cfg *dma_cfg,
-			     u32 dma_tx_phy, u32 chan)
+static void dwmac4_dma_init_tx_chan(void __iomem *ioaddr,
+				    struct stmmac_dma_cfg *dma_cfg,
+				    u32 dma_tx_phy, u32 chan)
 {
 	u32 value;
 	u32 txpbl = dma_cfg->txpbl ?: dma_cfg->pbl;
@@ -99,8 +99,8 @@ void dwmac4_dma_init_tx_chan(void __iomem *ioaddr,
 	writel(dma_tx_phy, ioaddr + DMA_CHAN_TX_BASE_ADDR(chan));
 }
 
-void dwmac4_dma_init_channel(void __iomem *ioaddr,
-			     struct stmmac_dma_cfg *dma_cfg, u32 chan)
+static void dwmac4_dma_init_channel(void __iomem *ioaddr,
+				    struct stmmac_dma_cfg *dma_cfg, u32 chan)
 {
 	u32 value;
 
-- 
2.11.0

