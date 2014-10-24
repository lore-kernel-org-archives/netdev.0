From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v3 2/5] ethernet: apm: xgene: remove unnecessary check
Date: Fri, 24 Oct 2014 07:42:07 +0530
Message-ID: <1414116730-4590-3-git-send-email-varkab@cdac.in>
References: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:49706 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbaJXCOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 22:14:21 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so560739pdi.30
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 19:14:20 -0700 (PDT)
In-Reply-To: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |   12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 3c208cc..f226594 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -761,10 +761,6 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	ndev = pdata->ndev;
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "enet_csr");
-	if (!res) {
-		dev_err(dev, "Resource enet_csr not defined\n");
-		return -ENODEV;
-	}
 	pdata->base_addr = devm_ioremap_resource(dev, res);
 	if (IS_ERR(pdata->base_addr)) {
 		dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
@@ -772,10 +768,6 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	}
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ring_csr");
-	if (!res) {
-		dev_err(dev, "Resource ring_csr not defined\n");
-		return -ENODEV;
-	}
 	pdata->ring_csr_addr = devm_ioremap_resource(dev, res);
 	if (IS_ERR(pdata->ring_csr_addr)) {
 		dev_err(dev, "Unable to retrieve ENET Ring CSR region\n");
@@ -783,10 +775,6 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	}
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ring_cmd");
-	if (!res) {
-		dev_err(dev, "Resource ring_cmd not defined\n");
-		return -ENODEV;
-	}
 	pdata->ring_cmd_addr = devm_ioremap_resource(dev, res);
 	if (IS_ERR(pdata->ring_cmd_addr)) {
 		dev_err(dev, "Unable to retrieve ENET Ring command region\n");
-- 
1.7.9.5
