From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] stmmac: pci: set default of the filter bins
Date: Thu, 30 Oct 2014 11:39:25 +0200
Message-ID: <1414661965-1140-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30935 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758162AbaJ3Jj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 05:39:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 3b57de958e2a brought the support for a different amount of the
filter bins, but didn't update the PCI driver accordingly. This patch appends
the default values when the device is enumerated via PCI bus.

Fixes: 3b57de958e2a (net: stmmac: Support devicetree configs for mcast and ucast filter entries)
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 655a23b..7fc1bbf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -32,7 +32,10 @@ static struct stmmac_dma_cfg dma_cfg;
 
 static void stmmac_default_data(void)
 {
+	struct plat_stmmacenet_data *plat = &plat_dat;
+
 	memset(&plat_dat, 0, sizeof(struct plat_stmmacenet_data));
+
 	plat_dat.bus_id = 1;
 	plat_dat.phy_addr = 0;
 	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
@@ -47,6 +50,12 @@ static void stmmac_default_data(void)
 	dma_cfg.pbl = 32;
 	dma_cfg.burst_len = DMA_AXI_BLEN_256;
 	plat_dat.dma_cfg = &dma_cfg;
+
+	/* Set default value for multicast hash bins */
+	plat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat->unicast_filter_entries = 1;
 }
 
 /**
-- 
2.1.1
