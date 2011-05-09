From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH] pch_gbe: support ML7223 IOH
Date: Mon,  9 May 2011 20:19:37 +0900
Message-ID: <1304939977-11728-1-git-send-email-tomoya-linux__8001.99497393823$1304940043$gmane$org@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
To: "David S. Miller" <davem@davemloft.net>,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jon Mason <jon.mason@exar.com>, netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11237 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751080Ab1EILUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 07:20:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support new device OKI SEMICONDUCTOR ML7223 IOH(Input/Output Hub).
The ML7223 IOH is for MP(Media Phone) use.
The ML7223 is companion chip for Intel Atom E6xx series.
The ML7223 is completely compatible for Intel EG20T PCH.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/Kconfig                |    8 +++++++-
 drivers/net/pch_gbe/pch_gbe_main.c |   11 +++++++++++
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dc280bc..6c884ef 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2536,7 +2536,7 @@ config S6GMAC
 source "drivers/net/stmmac/Kconfig"
 
 config PCH_GBE
-	tristate "PCH Gigabit Ethernet"
+	tristate "Intel EG20T PCH / OKI SEMICONDUCTOR ML7223 IOH GbE"
 	depends on PCI
 	select MII
 	---help---
@@ -2548,6 +2548,12 @@ config PCH_GBE
 	  to Gigabit Ethernet.
 	  This driver enables Gigabit Ethernet function.
 
+	  This driver also can be used for OKI SEMICONDUCTOR IOH(Input/
+	  Output Hub), ML7223.
+	  ML7223 IOH is for MP(Media Phone) use.
+	  ML7223 is companion chip for Intel Atom E6xx series.
+	  ML7223 is completely compatible for Intel EG20T PCH.
+
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 2ef2f9c..bd27e1d 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -34,6 +34,10 @@ const char pch_driver_version[] = DRV_VERSION;
 #define PCH_GBE_COPYBREAK_DEFAULT	256
 #define PCH_GBE_PCI_BAR			1
 
+/* Macros for ML7223 */
+#define PCI_VENDOR_ID_ROHM			0x10db
+#define PCI_DEVICE_ID_ROHM_ML7223_GBE		0x8013
+
 #define PCH_GBE_TX_WEIGHT         64
 #define PCH_GBE_RX_WEIGHT         64
 #define PCH_GBE_RX_BUFFER_WRITE   16
@@ -2420,6 +2424,13 @@ static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
 	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
 	 .class_mask = (0xFFFF00)
 	 },
+	{.vendor = PCI_VENDOR_ID_ROHM,
+	 .device = PCI_DEVICE_ID_ROHM_ML7223_GBE,
+	 .subvendor = PCI_ANY_ID,
+	 .subdevice = PCI_ANY_ID,
+	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
+	 .class_mask = (0xFFFF00)
+	 },
 	/* required last entry */
 	{0}
 };
-- 
1.7.4

