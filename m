From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: stmmac: ensure jumbo_frm error return is correctly checked for -ve value
Date: Fri,  2 Jun 2017 15:58:27 +0100
Message-ID: <20170602145827.21151-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The current comparison of entry < 0 will never be true since entry is an
unsigned integer. Cast entry to an int to ensure -ve error return values
from the call to jumbo_frm are correctly being caught.

Detected by CoverityScan, CID#1238760 ("Macro compares unsigned to 0")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 68a188e74c54..5cc19506ba85 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2996,7 +2996,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(is_jumbo) && likely(priv->synopsys_id <
 					 DWMAC_CORE_4_00)) {
 		entry = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
-		if (unlikely(entry < 0))
+		if (unlikely((int)entry < 0))
 			goto dma_map_err;
 	}
 
-- 
2.11.0
