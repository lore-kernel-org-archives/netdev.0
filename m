From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] stmmac: replace open coded __netdev_alloc_skb_ip_align() with actual call
Date: Wed, 20 May 2015 12:04:40 +0530
Message-ID: <1432103680-5612-1-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This also matches with the sibling call netdev_alloc_skb_ip_align() made in
rx fast path.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 05c146f718a3..42e1492ea845 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -975,13 +975,11 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 {
 	struct sk_buff *skb;
 
-	skb = __netdev_alloc_skb(priv->dev, priv->dma_buf_sz + NET_IP_ALIGN,
-				 flags);
+	skb = __netdev_alloc_skb_ip_align(priv->dev, priv->dma_buf_sz, flags);
 	if (!skb) {
 		pr_err("%s: Rx init fails; skb is NULL\n", __func__);
 		return -ENOMEM;
 	}
-	skb_reserve(skb, NET_IP_ALIGN);
 	priv->rx_skbuff[i] = skb;
 	priv->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
 						priv->dma_buf_sz,
-- 
1.9.1
