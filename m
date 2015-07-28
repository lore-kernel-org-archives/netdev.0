From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 04/17] stmmac: dwmac-socfpga: move socfpga_dwmac_probe function
Date: Wed, 29 Jul 2015 00:08:51 +0200
Message-ID: <1438121344-5304-5-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, dinguyen@opensource.altera.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:32833 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbbG1WJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:25 -0400
Received: by lbbyj8 with SMTP id yj8so83984584lbb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:24 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move socfpga_dwmac_probe in preparation for turning it into
a proper probe function.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 50 +++++++++++-----------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 8141c5b844ae..0df409e2edcd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -175,31 +175,6 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	return 0;
 }
 
-static void *socfpga_dwmac_probe(struct platform_device *pdev)
-{
-	struct device		*dev = &pdev->dev;
-	int			ret;
-	struct socfpga_dwmac	*dwmac;
-
-	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return ERR_PTR(-ENOMEM);
-
-	ret = socfpga_dwmac_parse_data(dwmac, dev);
-	if (ret) {
-		dev_err(dev, "Unable to parse OF data\n");
-		return ERR_PTR(ret);
-	}
-
-	ret = socfpga_dwmac_setup(dwmac);
-	if (ret) {
-		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
-		return ERR_PTR(ret);
-	}
-
-	return dwmac;
-}
-
 static void socfpga_dwmac_exit(struct platform_device *pdev, void *priv)
 {
 	struct socfpga_dwmac	*dwmac = priv;
@@ -257,6 +232,31 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
 	return ret;
 }
 
+static void *socfpga_dwmac_probe(struct platform_device *pdev)
+{
+	struct device		*dev = &pdev->dev;
+	int			ret;
+	struct socfpga_dwmac	*dwmac;
+
+	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
+	if (!dwmac)
+		return ERR_PTR(-ENOMEM);
+
+	ret = socfpga_dwmac_parse_data(dwmac, dev);
+	if (ret) {
+		dev_err(dev, "Unable to parse OF data\n");
+		return ERR_PTR(ret);
+	}
+
+	ret = socfpga_dwmac_setup(dwmac);
+	if (ret) {
+		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
+		return ERR_PTR(ret);
+	}
+
+	return dwmac;
+}
+
 static const struct stmmac_of_data socfpga_gmac_data = {
 	.setup = socfpga_dwmac_probe,
 	.init = socfpga_dwmac_init,
-- 
1.8.0
