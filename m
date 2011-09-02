From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 3/3] pch_gbe: support ML7831 IOH
Date: Fri,  2 Sep 2011 09:20:09 +0900
Message-ID: <1314922809-4041-3-git-send-email-toshiharu-linux@dsn.okisemi.com>
References: <1314922809-4041-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314922809-4041-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support new device OKI SEMICONDUCTOR ML7831 IOH(Input/Output Hub)

ML7831 is for general purpose use.
ML7831 is companion chip for Intel Atom E6xx series.
ML7831 is completely compatible for Intel EG20T PCH.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/Kconfig                |   11 ++++++-----
 drivers/net/pch_gbe/pch_gbe_main.c |   10 ++++++++++
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8d0314d..a44874e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2535,7 +2535,7 @@ config S6GMAC
 source "drivers/net/stmmac/Kconfig"
 
 config PCH_GBE
-	tristate "Intel EG20T PCH / OKI SEMICONDUCTOR ML7223 IOH GbE"
+	tristate "Intel EG20T PCH/OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
 	depends on PCI
 	select MII
 	---help---
@@ -2548,10 +2548,11 @@ config PCH_GBE
 	  This driver enables Gigabit Ethernet function.
 
 	  This driver also can be used for OKI SEMICONDUCTOR IOH(Input/
-	  Output Hub), ML7223.
-	  ML7223 IOH is for MP(Media Phone) use.
-	  ML7223 is companion chip for Intel Atom E6xx series.
-	  ML7223 is completely compatible for Intel EG20T PCH.
+	  Output Hub), ML7223/ML7831.
+	  ML7223 IOH is for MP(Media Phone) use. ML7831 IOH is for general
+	  purpose use.
+	  ML7223/ML7831 is companion chip for Intel Atom E6xx series.
+	  ML7223/ML7831 is completely compatible for Intel EG20T PCH.
 
 config FTGMAC100
 	tristate "Faraday FTGMAC100 Gigabit Ethernet support"
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 39ce0ee..567ff10 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -39,6 +39,9 @@ const char pch_driver_version[] = DRV_VERSION;
 #define PCI_VENDOR_ID_ROHM			0x10db
 #define PCI_DEVICE_ID_ROHM_ML7223_GBE		0x8013
 
+/* Macros for ML7831 */
+#define PCI_DEVICE_ID_ROHM_ML7831_GBE		0x8802
+
 #define PCH_GBE_TX_WEIGHT         64
 #define PCH_GBE_RX_WEIGHT         64
 #define PCH_GBE_RX_BUFFER_WRITE   16
@@ -2526,6 +2529,13 @@ static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
 	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
 	 .class_mask = (0xFFFF00)
 	 },
+	{.vendor = PCI_VENDOR_ID_ROHM,
+	 .device = PCI_DEVICE_ID_ROHM_ML7831_GBE,
+	 .subvendor = PCI_ANY_ID,
+	 .subdevice = PCI_ANY_ID,
+	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
+	 .class_mask = (0xFFFF00)
+	 },
 	/* required last entry */
 	{0}
 };
-- 
1.7.4.4
