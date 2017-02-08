From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 14/16] net: stmmac: remove dead code in stmmac_tx_clean
Date: Wed,  8 Feb 2017 09:31:19 +0100
Message-ID: <20170208083121.27949-15-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit cf32deec16e4 ("stmmac: add tx_skbuff_dma to save descriptors used by PTP"),
the struct dma_desc *p in stmmac_tx_clean was not used at all.

This patch remove this dead code.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 9805aa8..c5dc3f9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1109,13 +1109,6 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
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
