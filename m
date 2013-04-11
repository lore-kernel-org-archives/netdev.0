From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] net: ethernet: stmicro: stmmac: use devm_ioremap_resource()
Date: Thu, 11 Apr 2013 22:52:13 +0300
Message-ID: <1365709933-5796-1-git-send-email-silviupopescu1990@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	linux-kernel@vger.kernel.org,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert  use of devm_request_and_ioremap() to the newly introduced
devm_ioremap_resource() which provides more consistent error handling.

devm_ioremap_resource() provides its own error messages so all explicit
error messages can be removed from the failure code paths.

This was found with coccinelle.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index b43d68b..1d3780f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -88,11 +88,9 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	if (!res)
 		return -ENODEV;
 
-	addr = devm_request_and_ioremap(dev, res);
-	if (!addr) {
-		pr_err("%s: ERROR: memory mapping failed", __func__);
-		return -ENOMEM;
-	}
+	addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
 
 	if (pdev->dev.of_node) {
 		plat_dat = devm_kzalloc(&pdev->dev,
-- 
1.7.9.5
