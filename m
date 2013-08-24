From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: stmmac: fixed the pbl setting with DT
Date: Sat, 24 Aug 2013 15:31:43 +0900
Message-ID: <004f01cea093$9980e100$cc82a300$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>, davem@davemloft.net,
	=?ks_c_5601-1987?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:40672 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626Ab3HXGbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Aug 2013 02:31:45 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MS000GLTVGVB2C0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Sat, 24 Aug 2013 15:31:43 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixed the pbl(programmable burst length) setting 
using DT. Even though the default pbl is 8, If there is no 
pbl property in device tree file, pbl is set 0 and it causes 
bandwidth degradation.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 98e1988..142ee8e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -78,14 +78,18 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 		plat->force_sf_dma_mode = 1;
 	}
 
-	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg), GFP_KERNEL);
-	if (!dma_cfg)
-		return -ENOMEM;
-
-	plat->dma_cfg = dma_cfg;
-	of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
-	dma_cfg->fixed_burst = of_property_read_bool(np, "snps,fixed-burst");
-	dma_cfg->mixed_burst = of_property_read_bool(np, "snps,mixed-burst");
+	if (of_find_property(np, "snps,pbl", NULL)) {
+		dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
+				       GFP_KERNEL);
+		if (!dma_cfg)
+			return -ENOMEM;
+		plat->dma_cfg = dma_cfg;
+		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
+		dma_cfg->fixed_burst =
+			of_property_read_bool(np, "snps,fixed-burst");
+		dma_cfg->mixed_burst =
+			of_property_read_bool(np, "snps,mixed-burst");
+	}
 
 	return 0;
 }
-- 
1.7.10.4
