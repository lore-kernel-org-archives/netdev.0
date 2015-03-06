From: <dinguyen@opensource.altera.com>
Subject: [PATCHv2 net-next] net: stmmac: make reset control an optional requirement
Date: Fri, 6 Mar 2015 17:48:28 -0600
Message-ID: <1425685708-12600-1-git-send-email-dinguyen@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	Vince Bridgers <vbridger@opensource.altera.com>,
	"David S. Miller" <davem@davemloft.net>
To: <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dinh Nguyen <dinguyen@opensource.altera.com>

Not having a reset control line to the ethernet controller should not be a
hard failure. Instead, add support for deferred probing and just print out
a debug statement.

Signed-off-by: Dinh Nguyen <dinguyen@opensource.altera.com>
Cc: Vince Bridgers <vbridger@opensource.altera.com>
CC: David S. Miller <davem@davemloft.net>
---
v2: return EPROBE_DEFER directly as 'ret' is not used as return variable
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 3aad413..9987b34 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -89,7 +89,9 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 						  STMMAC_RESOURCE_NAME);
 	if (IS_ERR(dwmac->stmmac_rst)) {
 		dev_info(dev, "Could not get reset control!\n");
-		return -EINVAL;
+		if (PTR_ERR(dwmac->stmmac_rst) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		dwmac->stmmac_rst = NULL;
 	}
 
 	dwmac->interface = of_get_phy_mode(np);
-- 
2.2.1
