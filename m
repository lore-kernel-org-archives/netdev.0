From: varkabhadram@gmail.com
Subject: [PATCH net 7/7] net: cpamc: fix in releasing resources
Date: Thu, 10 Jul 2014 10:18:00 +0530
Message-ID: <1404967680-13206-8-git-send-email-varkabhadram@gmail.com>
References: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:52566 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbaGJEto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 00:49:44 -0400
Received: by mail-pa0-f53.google.com with SMTP id ey11so10425475pad.12
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 21:49:44 -0700 (PDT)
In-Reply-To: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

before registering the the net device this code freeing net device
by using the label 'fail'

fixed by introducing an another label 'out'

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index b6efe3e..b68c5b5 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1142,7 +1142,7 @@ static int cpmac_probe(struct platform_device *pdev)
 	mem = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
 	if (!mem) {
 		rc = -ENODEV;
-		goto fail;
+		goto out;
 	}
 
 	dev->irq = platform_get_irq_byname(pdev, "irq");
@@ -1170,7 +1170,7 @@ static int cpmac_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "Could not attach to PHY\n");
 
 		rc = PTR_ERR(priv->phy);
-		goto fail;
+		goto out;
 	}
 
 	rc = register_netdev(dev);
@@ -1189,6 +1189,7 @@ static int cpmac_probe(struct platform_device *pdev)
 
 fail:
 	free_netdev(dev);
+out:
 	return rc;
 }
 
-- 
1.7.9.5
