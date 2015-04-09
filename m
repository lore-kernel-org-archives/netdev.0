From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH] stmmac: devm_reset_control_get can return PROBE_DEFER
Date: Wed,  8 Apr 2015 18:41:34 -0700
Message-ID: <1428543694-41762-1-git-send-email-preid@electromag.com.au>
Cc: netdev@vger.kernel.org, Phil Reid <preid@electromag.com.au>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203.161.99.65.static.amnet.net.au ([203.161.99.65]:36817 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753702AbbDIBuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 21:50:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In socfpga_dwmac_parse_data forward error code from devm_reset_control_get.
This gives the driver another chance to laod if altr,rst-mgr is loaded after
the network driver.

Signed-off-by: Phil Reid <preid@electromag.com.au>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index e97074c..1cacea9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -91,7 +91,7 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 						  STMMAC_RESOURCE_NAME);
 	if (IS_ERR(dwmac->stmmac_rst)) {
 		dev_info(dev, "Could not get reset control!\n");
-		return -EINVAL;
+		return PTR_ERR(dwmac->stmmac_rst);
 	}
 
 	dwmac->interface = of_get_phy_mode(np);
-- 
1.8.3.1
