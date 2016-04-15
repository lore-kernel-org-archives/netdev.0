From: <dinguyen@opensource.altera.com>
Subject: [net-next PATCH] stmmac: socfpga: remove extra call to socfpga_dwmac_setup
Date: Thu, 14 Apr 2016 20:42:29 -0500
Message-ID: <1460684549-9549-1-git-send-email-dinguyen@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, <mgerlach@opensource.altera.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	Dinh Nguyen <dinguyen@opensource.altera.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0065.outbound.protection.outlook.com ([65.55.169.65]:41329
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751375AbcDOBty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 21:49:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@opensource.altera.com>

In the socfpga_dwmac_probe function, we have a call to socfpga_dwmac_setup,
which is already called from socfpga_dwmac_init later in the probe function.
Remove this extra call to socfpga_dwmac_setup.

Also we should not be calling socfpga_dwmac_setup() directly without wrapping
it around the proper reset assert/deasserts. That is because the
socfpga_dwmac_setup() is setting up PHY modes in the system manager, and it
is requires the EMAC's to be in reset during the PHY setup.

Reported-by: Matthew Gerlach <mgerlach@opensource.altera.com>
Signed-off-by: Dinh Nguyen <dinguyen@opensource.altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index f0d797a..41f4c58 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -267,12 +267,6 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 		return ret;
 	}
 
-	ret = socfpga_dwmac_setup(dwmac);
-	if (ret) {
-		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
-		return ret;
-	}
-
 	plat_dat->bsp_priv = dwmac;
 	plat_dat->init = socfpga_dwmac_init;
 	plat_dat->exit = socfpga_dwmac_exit;
-- 
2.6.2
