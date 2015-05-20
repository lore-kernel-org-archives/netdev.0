From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 1/4] stmmac: move driver data setting into stmmac_dvr_probe
Date: Wed, 20 May 2015 20:03:06 +0200
Message-ID: <1432144989-28283-2-git-send-email-manabian@gmail.com>
References: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:34249 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbbETSD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:03:29 -0400
Received: by laat2 with SMTP id t2so85048101laa.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:03:28 -0700 (PDT)
In-Reply-To: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move setting of driver data into stmmac_dvr_probe so the
other probe functions don't have to. This will help to
simplify the other probe functions later.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      | 2 --
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 --
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 05c146f718a3..fae9195c8ff7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2830,6 +2830,8 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	priv->ioaddr = addr;
 	priv->dev->base_addr = (unsigned long)addr;
 
+	dev_set_drvdata(device, priv);
+
 	/* Verify driver arguments */
 	stmmac_verify_args();
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 3bca908716e2..4743d0017d79 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -222,8 +222,6 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	priv->dev->irq = pdev->irq;
 	priv->wol_irq = pdev->irq;
 
-	pci_set_drvdata(pdev, priv->dev);
-
 	dev_dbg(&pdev->dev, "STMMAC PCI driver registration completed\n");
 
 	return 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ffe9e820b312..6db27dee0901 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -349,8 +349,6 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 	if (mac)
 		memcpy(priv->dev->dev_addr, mac, ETH_ALEN);
 
-	platform_set_drvdata(pdev, priv->dev);
-
 	pr_debug("STMMAC platform driver registration completed");
 
 	return 0;
-- 
1.8.0
