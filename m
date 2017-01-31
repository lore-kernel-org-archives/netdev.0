From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 15/17] net: stmmac: remove dead code in stmmac_tx_clean
Date: Tue, 31 Jan 2017 10:11:50 +0100
Message-ID: <20170131091152.13842-16-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit cf32deec16e4 ("stmmac: add tx_skbuff_dma to save descriptors used by PTP"),
the struct dma_desc *p in stmmac_tx_clean was not used at all.

This patch remove this dead code.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3d52b8c..b494bc2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1124,13 +1124,6 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 	int i;
 
 	for (i = 0; i < DMA_TX_SIZE; i++) {
-		struct dma_desc *p;
-
-		if (priv->extend_desc)
-			p = &((priv->dma_etx + i)->basic);
-		else
-			p = priv->dma_tx + i;
-
 		if (priv->tx_skbuff_dma[i].buf) {
 			if (priv->tx_skbuff_dma[i].map_as_page)
 				dma_unmap_page(priv->device,
-- 
2.10.2
