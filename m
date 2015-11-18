From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 01/27] adm80211: move under admtek vendor directory
Date: Wed, 18 Nov 2015 16:45:40 +0200
Message-ID: <1447857966-19560-2-git-send-email-kvalo@codeaurora.org>
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
 MAINTAINERS                                 |    2 +-
 drivers/net/wireless/Kconfig                |   29 ++-----------------
 drivers/net/wireless/Makefile               |    4 +--
 drivers/net/wireless/admtek/Kconfig         |   41 +++++++++++++++++++++++++++
 drivers/net/wireless/admtek/Makefile        |    1 +
 drivers/net/wireless/{ => admtek}/adm8211.c |    0
 drivers/net/wireless/{ => admtek}/adm8211.h |    0
 7 files changed, 47 insertions(+), 30 deletions(-)
 create mode 100644 drivers/net/wireless/admtek/Kconfig
 create mode 100644 drivers/net/wireless/admtek/Makefile
 rename drivers/net/wireless/{ => admtek}/adm8211.c (100%)
 rename drivers/net/wireless/{ => admtek}/adm8211.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 35fe7ae0492e..f1adb66094f1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -388,7 +388,7 @@ ADM8211 WIRELESS DRIVER
 L:	linux-wireless@vger.kernel.org
 W:	http://wireless.kernel.org/
 S:	Orphan
-F:	drivers/net/wireless/adm8211.*
+F:	drivers/net/wireless/admtek/adm8211.*
 
 ADP1653 FLASH CONTROLLER DRIVER
 M:	Sakari Ailus <sakari.ailus@iki.fi>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index f9f94229bf1b..7d8f47117c4d 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -17,6 +17,8 @@ menuconfig WLAN
 
 if WLAN
 
+source "drivers/net/wireless/admtek/Kconfig"
+
 config PCMCIA_RAYCS
 	tristate "Aviator/Raytheon 2.4GHz wireless support"
 	depends on PCMCIA
@@ -214,33 +216,6 @@ config USB_NET_RNDIS_WLAN
 
 	  If you choose to build a module, it'll be called rndis_wlan.
 
-config ADM8211
-	tristate "ADMtek ADM8211 support"
-	depends on MAC80211 && PCI
-	select CRC32
-	select EEPROM_93CX6
-	---help---
-	  This driver is for ADM8211A, ADM8211B, and ADM8211C based cards.
-	  These are PCI/mini-PCI/Cardbus 802.11b chips found in cards such as:
-
-	  Xterasys Cardbus XN-2411b
-	  Blitz NetWave Point PC
-	  TrendNet 221pc
-	  Belkin F5D6001
-	  SMC 2635W
-	  Linksys WPC11 v1
-	  Fiberline FL-WL-200X
-	  3com Office Connect (3CRSHPW796)
-	  Corega WLPCIB-11
-	  SMC 2602W V2 EU
-	  D-Link DWL-520 Revision C
-
-	  However, some of these cards have been replaced with other chips
-	  like the RTL8180L (Xterasys Cardbus XN-2411b, Belkin F5D6001) or
-	  the Ralink RT2400 (SMC2635W) without a model number change.
-
-	  Thanks to Infineon-ADMtek for their support of this driver.
-
 source "drivers/net/wireless/realtek/rtl818x/Kconfig"
 
 config MAC80211_HWSIM
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 740fdd353c5d..be215f43ec1d 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -2,6 +2,8 @@
 # Makefile for the Linux Wireless network device drivers.
 #
 
+obj-$(CONFIG_WLAN_VENDOR_ADMTEK) += admtek/
+
 obj-$(CONFIG_IPW2100) += ipw2x00/
 obj-$(CONFIG_IPW2200) += ipw2x00/
 
@@ -35,8 +37,6 @@ obj-$(CONFIG_LIBERTAS)		+= libertas/
 
 obj-$(CONFIG_LIBERTAS_THINFIRM)	+= libertas_tf/
 
-obj-$(CONFIG_ADM8211)	+= adm8211.o
-
 obj-$(CONFIG_MWL8K)	+= mwl8k.o
 
 obj-$(CONFIG_IWLWIFI)	+= iwlwifi/
diff --git a/drivers/net/wireless/admtek/Kconfig b/drivers/net/wireless/admtek/Kconfig
new file mode 100644
index 000000000000..d5a2dc728078
--- /dev/null
+++ b/drivers/net/wireless/admtek/Kconfig
@@ -0,0 +1,41 @@
+config WLAN_VENDOR_ADMTEK
+	bool "ADMtek devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_ADMTEK
+
+config ADM8211
+	tristate "ADMtek ADM8211 support"
+	depends on MAC80211 && PCI
+	select CRC32
+	select EEPROM_93CX6
+	---help---
+	  This driver is for ADM8211A, ADM8211B, and ADM8211C based cards.
+	  These are PCI/mini-PCI/Cardbus 802.11b chips found in cards such as:
+
+	  Xterasys Cardbus XN-2411b
+	  Blitz NetWave Point PC
+	  TrendNet 221pc
+	  Belkin F5D6001
+	  SMC 2635W
+	  Linksys WPC11 v1
+	  Fiberline FL-WL-200X
+	  3com Office Connect (3CRSHPW796)
+	  Corega WLPCIB-11
+	  SMC 2602W V2 EU
+	  D-Link DWL-520 Revision C
+
+	  However, some of these cards have been replaced with other chips
+	  like the RTL8180L (Xterasys Cardbus XN-2411b, Belkin F5D6001) or
+	  the Ralink RT2400 (SMC2635W) without a model number change.
+
+	  Thanks to Infineon-ADMtek for their support of this driver.
+
+endif # WLAN_VENDOR_ADMTEK
diff --git a/drivers/net/wireless/admtek/Makefile b/drivers/net/wireless/admtek/Makefile
new file mode 100644
index 000000000000..9cca7e571cdd
--- /dev/null
+++ b/drivers/net/wireless/admtek/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_ADM8211)	+= adm8211.o
diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/admtek/adm8211.c
similarity index 100%
rename from drivers/net/wireless/adm8211.c
rename to drivers/net/wireless/admtek/adm8211.c
diff --git a/drivers/net/wireless/adm8211.h b/drivers/net/wireless/admtek/adm8211.h
similarity index 100%
rename from drivers/net/wireless/adm8211.h
rename to drivers/net/wireless/admtek/adm8211.h
-- 
1.7.9.5
