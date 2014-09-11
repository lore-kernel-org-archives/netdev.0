From: weiyj_lk@163.com
Subject: [PATCH -next] net: stmmac: fix return value check in socfpga_dwmac_parse_data()
Date: Fri, 12 Sep 2014 07:12:57 +0800
Message-ID: <1410477177-5681-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:54506 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215AbaIKXNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 19:13:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function devm_ioremap_resource() returns
ERR_PTR() and never returns NULL. The NULL test in the return
value check should be replaced with IS_ERR().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index ddc6115..3aad413 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -120,9 +120,9 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 		}
 
 		dwmac->splitter_base = devm_ioremap_resource(dev, &res_splitter);
-		if (!dwmac->splitter_base) {
+		if (IS_ERR(dwmac->splitter_base)) {
 			dev_info(dev, "Failed to mapping emac splitter\n");
-			return -EINVAL;
+			return PTR_ERR(dwmac->splitter_base);
 		}
 	}
 
