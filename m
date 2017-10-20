From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 1/3] net: stmmac: Add missing call to dev_kfree_skb()
Date: Fri, 20 Oct 2017 14:37:34 +0100
Message-ID: <5f6cab10ae28cb66374dcaeb8ba5d169d6fda783.1508506265.git.joabreu@synopsys.com>
References: <cover.1508506265.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1508506265.git.joabreu@synopsys.com>
In-Reply-To: <cover.1508506265.git.joabreu@synopsys.com>
References: <cover.1508506265.git.joabreu@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When RX HW timestamp is enabled and a frame is discarded we are
not freeing the skb but instead only setting to NULL the entry.

Add a call to dev_kfree_skb_any() so that skb entry is correctly
freed.

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0e1b0a3..f7b7906 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3358,6 +3358,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 				 * them in stmmac_rx_refill() function so that
 				 * device can reuse it.
 				 */
+				dev_kfree_skb_any(rx_q->rx_skbuff[entry]);
 				rx_q->rx_skbuff[entry] = NULL;
 				dma_unmap_single(priv->device,
 						 rx_q->rx_skbuff_dma[entry],
-- 
1.9.1
