From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] stmmac: pci: set default of the filter bins
Date: Fri, 31 Oct 2014 18:28:03 +0200
Message-ID: <1414772883-29503-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	stable@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit 3b57de958e2a brought the support for a different amount of the
filter bins, but didn't update the PCI driver accordingly. This patch appends
the default values when the device is enumerated via PCI bus.

Fixes: 3b57de958e2a (net: stmmac: Support devicetree configs for mcast and ucast filter entries)
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: stable@vger.kernel.org
---
Since v1:
- fix ugly style
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 655a23b..e17a970 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -33,6 +33,7 @@ static struct stmmac_dma_cfg dma_cfg;
 static void stmmac_default_data(void)
 {
 	memset(&plat_dat, 0, sizeof(struct plat_stmmacenet_data));
+
 	plat_dat.bus_id = 1;
 	plat_dat.phy_addr = 0;
 	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
@@ -47,6 +48,12 @@ static void stmmac_default_data(void)
 	dma_cfg.pbl = 32;
 	dma_cfg.burst_len = DMA_AXI_BLEN_256;
 	plat_dat.dma_cfg = &dma_cfg;
+
+	/* Set default value for multicast hash bins */
+	plat_dat.multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat_dat.unicast_filter_entries = 1;
 }
 
 /**
-- 
2.1.1
