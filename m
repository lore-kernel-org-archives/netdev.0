From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: stmmac: make const array route_possibilities static
Date: Tue, 11 Jul 2017 12:18:48 +0100
Message-ID: <20170711111848.14469-1-colin.king@canonical.com>
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

Don't populate array route_possibilities on the stack but make it
static const.  Makes the object code a little smaller by 85 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
   9901	   2448	      0	  12349	   303d	dwmac4_core.o

After:
   text	   data	    bss	    dec	    hex	filename
   9760	   2504	      0	  12264	   2fe8	dwmac4_core.o

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index f233bf8b4ebb..c4407e8e39a3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -117,7 +117,7 @@ static void dwmac4_tx_queue_routing(struct mac_device_info *hw,
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
 
-	const struct stmmac_rx_routing route_possibilities[] = {
+	static const struct stmmac_rx_routing route_possibilities[] = {
 		{ GMAC_RXQCTRL_AVCPQ_MASK, GMAC_RXQCTRL_AVCPQ_SHIFT },
 		{ GMAC_RXQCTRL_PTPQ_MASK, GMAC_RXQCTRL_PTPQ_SHIFT },
 		{ GMAC_RXQCTRL_DCBCPQ_MASK, GMAC_RXQCTRL_DCBCPQ_SHIFT },
-- 
2.11.0
