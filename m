From: Ley Foon Tan <lftan@altera.com>
Subject: [PATCH] net: stmmac: fix warning from Sparse for socfpga
Date: Tue, 26 Aug 2014 15:11:16 +0800
Message-ID: <1409037076-14775-1-git-send-email-lftan@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ley Foon Tan <lftan@altera.com>, <lftan.linux@gmail.com>,
	"Giuseppe Cavallaro" <peppe.cavallaro@st.com>,
	Vince Bridgers <vbridger@altera.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Warning:
drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:41:
sparse: cast removes address space of expression
drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:38:
sparse: incorrect type in assignment (different address spaces)

Signed-off-by: Ley Foon Tan <lftan@altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index cd613d7..c1addce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -119,7 +119,8 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 			return -EINVAL;
 		}
 
-		dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
+		dwmac->splitter_base =
+			(void __iomem *)devm_ioremap_resource(dev,
 			&res_splitter);
 		if (!dwmac->splitter_base) {
 			dev_info(dev, "Failed to mapping emac splitter\n");
-- 
1.8.2.1
