From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] drivers: net: phy: xgene: Remove redundant dev_err call in xgene_mdio_probe()
Date: Thu, 28 Jul 2016 02:12:17 +0000
Message-ID: <1469671937-13265-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32780 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062AbcG1CMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 22:12:32 -0400
Received: by mail-pf0-f195.google.com with SMTP id i6so2778978pfe.0
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 19:12:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a error message within devm_ioremap_resource
already, so remove the dev_err call to avoid redundant
error message.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/phy/mdio-xgene.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/phy/mdio-xgene.c b/drivers/net/phy/mdio-xgene.c
index d94a978..7756748 100644
--- a/drivers/net/phy/mdio-xgene.c
+++ b/drivers/net/phy/mdio-xgene.c
@@ -345,10 +345,8 @@ static int xgene_mdio_probe(struct platform_device *pdev)
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	csr_base = devm_ioremap_resource(dev, res);
-	if (IS_ERR(csr_base)) {
-		dev_err(dev, "Unable to retrieve mac CSR region\n");
+	if (IS_ERR(csr_base))
 		return PTR_ERR(csr_base);
-	}
 	pdata->mac_csr_addr = csr_base;
 	pdata->mdio_csr_addr = csr_base + BLOCK_XG_MDIO_CSR_OFFSET;
 	pdata->diag_csr_addr = csr_base + BLOCK_DIAG_CSR_OFFSET;
