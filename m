From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 3/3] stmmac: pci: add MSI support for Intel Quark X1000
Date: Tue, 27 Jan 2015 21:44:49 +0200
Message-ID: <1422387889-21559-4-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7499 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759484AbbA0TpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 14:45:06 -0500
In-Reply-To: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

In Intel Quark SoC X1000, both of the Ethernet controllers support
MSI interrupt handling. This patch enables them to use MSI interrupt
servicing in stmmac_pci for Intel Quark X1000.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 50f3c50..3bca908 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -212,6 +212,8 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	} else
 		stmmac_default_data(plat);
 
+	pci_enable_msi(pdev);
+
 	priv = stmmac_dvr_probe(&pdev->dev, plat, pcim_iomap_table(pdev)[i]);
 	if (IS_ERR(priv)) {
 		dev_err(&pdev->dev, "%s: main driver probe failed\n", __func__);
-- 
2.1.4
