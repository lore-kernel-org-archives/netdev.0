From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 4/5] stmmac: pci: set default filter bins
Date: Tue, 21 Oct 2014 19:35:32 +0300
Message-ID: <1413909333-16380-5-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24314 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932304AbaJUQuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 12:50:00 -0400
In-Reply-To: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 3b57de958e2a bring a support for different amount of filter bins,
but didn't update PCI driver accordingly. This patch append default values when
device is enumerated via PCI bus.

Fixes: 3b57de958e2a (net: stmmac: Support devicetree configs for mcast and ucast filter entries)
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index c16f74b..22cb5ff 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -67,6 +67,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	int ret = 0;
 	struct stmmac_priv *priv = NULL;
 	int pci_bar = 0;
+	struct plat_stmmacenet_data *plat = &plat_dat;
 
 	/* Enable pci device */
 	ret = pcim_enable_device(pdev);
@@ -83,7 +84,13 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	stmmac_default_data();
 
-	priv = stmmac_dvr_probe(&pdev->dev, &plat_dat,
+	/* Set default value for multicast hash bins */
+	plat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat->unicast_filter_entries = 1;
+
+	priv = stmmac_dvr_probe(&pdev->dev, plat,
 				pcim_iomap_table(pdev)[pci_bar]);
 	if (IS_ERR(priv)) {
 		dev_err(&pdev->dev, "%s: main driver probe failed\n", __func__);
-- 
2.1.1
