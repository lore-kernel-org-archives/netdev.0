From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] r6040: remove duplicate call to the pci_set_drvdata
Date: Sat,  7 Jul 2012 11:37:35 +0530
Message-ID: <1341641255-26429-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34107 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab2GGGHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 02:07:44 -0400
Received: by pbbrp8 with SMTP id rp8so15817535pbb.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 23:07:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pci_set_drvdata is called twice at the remove path of driver,
call it once.

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index d1827e8..9acc026 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1256,7 +1256,6 @@ static void __devexit r6040_remove_one(struct pci_dev *pdev)
 	kfree(lp->mii_bus->irq);
 	mdiobus_free(lp->mii_bus);
 	netif_napi_del(&lp->napi);
-	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, lp->base);
 	pci_release_regions(pdev);
 	free_netdev(dev);
-- 
1.7.9.5
