From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 2/3] net: stmmac: Fix error handling path in 'alloc_dma_tx_desc_resources()'
Date: Sat,  8 Jul 2017 09:46:43 +0200
Message-ID: <41bce9018e1acec009ed184ba238f495a678297e.1499499451.git.christophe.jaillet@wanadoo.fr>
References: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the first 'kmalloc_array' within the loop fails, we should free what
as already been allocated, as done in all other error handling path.

Fixes: ce736788e8a9 ("net: stmmac: adding multiple buffers for TX")
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4322fa4a13e8..07d486a70118 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1561,7 +1561,7 @@ static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
 						    sizeof(*tx_q->tx_skbuff_dma),
 						    GFP_KERNEL);
 		if (!tx_q->tx_skbuff_dma)
-			return -ENOMEM;
+			goto err_dma_buffers;
 
 		tx_q->tx_skbuff = kmalloc_array(DMA_TX_SIZE,
 						sizeof(struct sk_buff *),
-- 
2.11.0
