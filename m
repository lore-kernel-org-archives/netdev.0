From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 4/4] stmmac: pci: convert to use dev_* macros
Date: Wed,  5 Nov 2014 12:27:29 +0200
Message-ID: <1415183249-9231-5-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1415183249-9231-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19854 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbaKEK2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 05:28:08 -0500
In-Reply-To: <1415183249-9231-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of pr_* macros let's use dev_* macros which provide device name.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 5357a3f..5084699 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -78,8 +78,8 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	/* Enable pci device */
 	ret = pcim_enable_device(pdev);
 	if (ret) {
-		pr_err("%s : ERROR: failed to enable %s device\n", __func__,
-		       pci_name(pdev));
+		dev_err(&pdev->dev, "%s: ERROR: failed to enable device\n",
+			__func__);
 		return ret;
 	}
 
@@ -100,7 +100,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	priv = stmmac_dvr_probe(&pdev->dev, &plat_dat,
 				pcim_iomap_table(pdev)[i]);
 	if (IS_ERR(priv)) {
-		pr_err("%s: main driver probe failed", __func__);
+		dev_err(&pdev->dev, "%s: main driver probe failed\n", __func__);
 		return PTR_ERR(priv);
 	}
 	priv->dev->irq = pdev->irq;
@@ -108,7 +108,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, priv->dev);
 
-	pr_debug("STMMAC platform driver registration completed");
+	dev_dbg(&pdev->dev, "STMMAC PCI driver registration completed\n");
 
 	return 0;
 }
-- 
2.1.1
