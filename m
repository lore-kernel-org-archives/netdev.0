From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH 14/15] ethernet: stmicro: stmmac: stmmac_platform: add missing of_node_put after calling of_parse_phandle
Date: Wed, 27 Jul 2016 10:20:47 +0800
Message-ID: <1469586048-15697-15-git-send-email-peter.chen@nxp.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <vbridger@opensource.altera.com>,
	<isubramanian@apm.com>, <kchudgar@apm.com>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<alexandre.torgue@st.com>, <mugunthanvnm@ti.com>,
	<tremyfr@gmail.com>, <wxt@rock-chips.com>, <arnd@arndb.de>,
	<david.daney@cavium.com>, <huangdaode@hisilicon.com>,
	<jszhang@marvell.com>, Peter Chen <peter.chen@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0062.outbound.protection.outlook.com ([104.47.38.62]:36800
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161400AbcG0Cpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 22:45:46 -0400
In-Reply-To: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

Signed-off-by: Peter Chen <peter.chen@nxp.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f7dfc0a..8d88782 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -113,8 +113,10 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 		return NULL;
 
 	axi = kzalloc(sizeof(*axi), GFP_KERNEL);
-	if (!axi)
+	if (!axi) {
+		of_node_put(np);
 		return ERR_PTR(-ENOMEM);
+	}
 
 	axi->axi_lpi_en = of_property_read_bool(np, "snps,lpi_en");
 	axi->axi_xit_frm = of_property_read_bool(np, "snps,xit_frm");
@@ -127,6 +129,7 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 	of_property_read_u32(np, "snps,wr_osr_lmt", &axi->axi_wr_osr_lmt);
 	of_property_read_u32(np, "snps,rd_osr_lmt", &axi->axi_rd_osr_lmt);
 	of_property_read_u32_array(np, "snps,blen", axi->axi_blen, AXI_BLEN);
+	of_node_put(np);
 
 	return axi;
 }
-- 
1.9.1
