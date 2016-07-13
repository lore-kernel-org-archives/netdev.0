From: weiyj_lk@163.com
Subject: [PATCH -next] stmmac: dwmac-socfpga: remove redundant dev_err call in socfpga_dwmac_parse_data()
Date: Wed, 13 Jul 2016 12:46:40 +0000
Message-ID: <1468414000-2860-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:54953 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbcGMMq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 08:46:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

There is a error message within devm_ioremap_resource
already, so remove the dev_err call to avoid redundant
error message.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 3bc1fa2..edd20c3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -165,12 +165,8 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 			dwmac->splitter_base =
 			    devm_ioremap_resource(dev, &res_splitter);
 
-			if (IS_ERR(dwmac->splitter_base)) {
-				dev_err(dev,
-					"%s: ERROR: failed mapping emac splitter\n",
-					__func__);
+			if (IS_ERR(dwmac->splitter_base))
 				return PTR_ERR(dwmac->splitter_base);
-			}
 		}
 
 		index = of_property_match_string(np_sgmii_adapter, "reg-names",
@@ -188,11 +184,8 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 			dwmac->pcs.sgmii_adapter_base =
 			    devm_ioremap_resource(dev, &res_sgmii_adapter);
 
-			if (IS_ERR(dwmac->pcs.sgmii_adapter_base)) {
-				dev_err(dev, "%s: failed to mapping adapter\n",
-					__func__);
+			if (IS_ERR(dwmac->pcs.sgmii_adapter_base))
 				return PTR_ERR(dwmac->pcs.sgmii_adapter_base);
-			}
 		}
 
 		index = of_property_match_string(np_sgmii_adapter, "reg-names",
@@ -210,12 +203,8 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 			dwmac->pcs.tse_pcs_base =
 			    devm_ioremap_resource(dev, &res_tse_pcs);
 
-			if (IS_ERR(dwmac->pcs.tse_pcs_base)) {
-				dev_err(dev,
-					"%s: ERROR: failed mapping tse control port\n",
-					__func__);
+			if (IS_ERR(dwmac->pcs.tse_pcs_base))
 				return PTR_ERR(dwmac->pcs.tse_pcs_base);
-			}
 		}
 	}
 	dwmac->reg_offset = reg_offset;
