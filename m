From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 15/27] zd1201: move under zydas vendor directory
Date: Wed, 18 Nov 2015 16:45:54 +0200
Message-ID: <1447857966-19560-16-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part of reorganising wireless drivers directory and Kconfig.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 MAINTAINERS                               |    2 +-
 drivers/net/wireless/Kconfig              |   20 +----------------
 drivers/net/wireless/Makefile             |    3 +--
 drivers/net/wireless/zydas/Kconfig        |   33 +++++++++++++++++++++++++++++
 drivers/net/wireless/zydas/Makefile       |    1 +
 drivers/net/wireless/{ => zydas}/zd1201.c |    0
 drivers/net/wireless/{ => zydas}/zd1201.h |    0
 7 files changed, 37 insertions(+), 22 deletions(-)
 create mode 100644 drivers/net/wireless/zydas/Kconfig
 create mode 100644 drivers/net/wireless/zydas/Makefile
 rename drivers/net/wireless/{ => zydas}/zd1201.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1201.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index e622877aaab4..ec098370ef3d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11252,7 +11252,7 @@ USB ZD1201 DRIVER
 L:	linux-wireless@vger.kernel.org
 W:	http://linux-lc100020.sourceforge.net
 S:	Orphan
-F:	drivers/net/wireless/zd1201.*
+F:	drivers/net/wireless/zydas/zd1201.*
 
 USB ZR364XX DRIVER
 M:	Antoine Jacquet <royale@zerezo.com>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 315982a5ee73..35155e2dc8bf 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -24,6 +24,7 @@ source "drivers/net/wireless/cisco/Kconfig"
 source "drivers/net/wireless/intel/Kconfig"
 source "drivers/net/wireless/marvell/Kconfig"
 source "drivers/net/wireless/st/Kconfig"
+source "drivers/net/wireless/zydas/Kconfig"
 
 config PCMCIA_RAYCS
 	tristate "Aviator/Raytheon 2.4GHz wireless support"
@@ -70,25 +71,6 @@ config PRISM54
 
 	  When built as module you get the module prism54
 
-config USB_ZD1201
-	tristate "USB ZD1201 based Wireless device support"
-	depends on CFG80211 && USB
-	select WIRELESS_EXT
-	select WEXT_PRIV
-	select FW_LOADER
-	---help---
-	  Say Y if you want to use wireless LAN adapters based on the ZyDAS
-	  ZD1201 chip.
-
-	  This driver makes the adapter appear as a normal Ethernet interface,
-	  typically on wlan0.
-
-	  The zd1201 device requires external firmware to be loaded.
-	  This can be found at http://linux-lc100020.sourceforge.net/
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called zd1201.
-
 config USB_NET_RNDIS_WLAN
 	tristate "Wireless RNDIS USB support"
 	depends on USB
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 9498753f596b..4ee6d6d08743 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 obj-$(CONFIG_WLAN_VENDOR_INTEL) += intel/
 obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
+obj-$(CONFIG_WLAN_VENDOR_ZYDAS) += zydas/
 
 obj-$(CONFIG_HERMES)		+= orinoco/
 
@@ -24,8 +25,6 @@ obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
 
 obj-$(CONFIG_USB_NET_RNDIS_WLAN)	+= rndis_wlan.o
 
-obj-$(CONFIG_USB_ZD1201)	+= zd1201.o
-
 obj-$(CONFIG_RT2X00)	+= rt2x00/
 
 obj-$(CONFIG_WL_MEDIATEK)	+= mediatek/
diff --git a/drivers/net/wireless/zydas/Kconfig b/drivers/net/wireless/zydas/Kconfig
new file mode 100644
index 000000000000..6140dfa04fed
--- /dev/null
+++ b/drivers/net/wireless/zydas/Kconfig
@@ -0,0 +1,33 @@
+config WLAN_VENDOR_ZYDAS
+	bool "ZyDAS devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_ZYDAS
+
+config USB_ZD1201
+	tristate "USB ZD1201 based Wireless device support"
+	depends on CFG80211 && USB
+	select WIRELESS_EXT
+	select WEXT_PRIV
+	select FW_LOADER
+	---help---
+	  Say Y if you want to use wireless LAN adapters based on the ZyDAS
+	  ZD1201 chip.
+
+	  This driver makes the adapter appear as a normal Ethernet interface,
+	  typically on wlan0.
+
+	  The zd1201 device requires external firmware to be loaded.
+	  This can be found at http://linux-lc100020.sourceforge.net/
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called zd1201.
+
+endif # WLAN_VENDOR_ZYDAS
diff --git a/drivers/net/wireless/zydas/Makefile b/drivers/net/wireless/zydas/Makefile
new file mode 100644
index 000000000000..37179ef890ea
--- /dev/null
+++ b/drivers/net/wireless/zydas/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_USB_ZD1201)	+= zd1201.o
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zydas/zd1201.c
similarity index 100%
rename from drivers/net/wireless/zd1201.c
rename to drivers/net/wireless/zydas/zd1201.c
diff --git a/drivers/net/wireless/zd1201.h b/drivers/net/wireless/zydas/zd1201.h
similarity index 100%
rename from drivers/net/wireless/zd1201.h
rename to drivers/net/wireless/zydas/zd1201.h
-- 
1.7.9.5
