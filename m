From: varkabhadram@gmail.com
Subject: [PATCH net v2 7/7] net: cpmac: fix in releasing resources
Date: Thu, 10 Jul 2014 11:05:45 +0530
Message-ID: <1404970545-26508-8-git-send-email-varkabhadram@gmail.com>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:48543 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaGJFh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 01:37:26 -0400
Received: by mail-pd0-f169.google.com with SMTP id ft15so3427038pdb.14
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 22:37:25 -0700 (PDT)
In-Reply-To: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
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
