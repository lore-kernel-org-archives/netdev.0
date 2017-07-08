From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 1/3] net: stmmac: Fix error handling path in 'alloc_dma_rx_desc_resources()'
Date: Sat,  8 Jul 2017 09:46:33 +0200
Message-ID: <12c5a0a87b6ef1ae40e35e247703082a671f2934.1499499451.git.christophe.jaillet@wanadoo.fr>
References: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the first 'kmalloc_array' within the loop fails, we should free what
as already been allocated, as done in all other error handling path.

Fixes: 54139cf3bb33 ("net: stmmac: adding multiple buffers for rx")
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 19bba6281dab..4322fa4a13e8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1498,7 +1498,7 @@ static int alloc_dma_rx_desc_resources(struct stmmac_priv *priv)
 						    sizeof(dma_addr_t),
 						    GFP_KERNEL);
 		if (!rx_q->rx_skbuff_dma)
-			return -ENOMEM;
+			goto err_dma;
 
 		rx_q->rx_skbuff = kmalloc_array(DMA_RX_SIZE,
 						sizeof(struct sk_buff *),
-- 
2.11.0

