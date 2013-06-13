From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH net-next] stmmac: added device tree support for fixed_phy and
 phy_addr
Date: Thu, 13 Jun 2013 10:25:44 +0900
Message-ID: <019301ce67d4$ed1e32b0$c75a9810$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	=?ks_c_5601-1987?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	davem@davemloft.net, cpgs@samsung.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:36090 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681Ab3FMBZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 21:25:48 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOB000UP5AS72F0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 13 Jun 2013 10:25:46 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds device tree support for fixed_phy and phy_addr it means
fixed_phy and phy_addr can be set in device tree file. "fixed_phy" and
"phy_addr" can be added in the device tree blob. 

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1d3780f..33ba995 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -34,6 +34,7 @@ static int stmmac_probe_config_dt(struct platform_device
*pdev,
 				  const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
+	u32 phy_addr;
 
 	if (!np)
 		return -ENODEV;
@@ -56,6 +57,12 @@ static int stmmac_probe_config_dt(struct platform_device
*pdev,
 		plat->pmt = 1;
 	}
 
+	if (of_find_property(np, "fixed_phy", NULL)) {
+		plat->phy_bus_name = "fixed";
+		of_property_read_u32(np, "phy_addr", &phy_addr);
+		plat->phy_addr = phy_addr;
+	}
+
 	return 0;
 }
 #else
-- 
1.7.10.4
