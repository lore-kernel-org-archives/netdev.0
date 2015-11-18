From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 25/27] ti: unify Kconfig with other vendors
Date: Wed, 18 Nov 2015 16:46:04 +0200
Message-ID: <1447857966-19560-26-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename WL_TI to WLAN_VENDOR_TI to match with other vendor configs and make sure
that it's enabled by default in new configs. Convert menuconfigs to regular
configs to unify the wireless drivers menuconfig. Part of reorganising wireless
drivers directory and Kconfig.

Also remove WLCORE dependency to WL_TI. It should not be needed as WLCORE is
already under if  WLAN_VENDOR_TI.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 drivers/net/wireless/Kconfig           |    2 +-
 drivers/net/wireless/Makefile          |    3 +--
 drivers/net/wireless/ti/Kconfig        |   18 +++++++++++-------
 drivers/net/wireless/ti/wl1251/Kconfig |    2 +-
 drivers/net/wireless/ti/wlcore/Kconfig |    2 +-
 5 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 2225e06611fa..cb115db309ce 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -29,6 +29,7 @@ source "drivers/net/wireless/ralink/Kconfig"
 source "drivers/net/wireless/realtek/Kconfig"
 source "drivers/net/wireless/rsi/Kconfig"
 source "drivers/net/wireless/st/Kconfig"
+source "drivers/net/wireless/ti/Kconfig"
 source "drivers/net/wireless/zydas/Kconfig"
 
 config PCMCIA_RAYCS
@@ -99,6 +100,5 @@ config MAC80211_HWSIM
 	  called mac80211_hwsim.  If unsure, say N.
 
 source "drivers/net/wireless/ath/Kconfig"
-source "drivers/net/wireless/ti/Kconfig"
 
 endif # WLAN
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 0fa909072846..8c99b9faab09 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_WLAN_VENDOR_RALINK) += ralink/
 obj-$(CONFIG_WLAN_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_WLAN_VENDOR_RSI) += rsi/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
+obj-$(CONFIG_WLAN_VENDOR_TI) += ti/
 obj-$(CONFIG_WLAN_VENDOR_ZYDAS) += zydas/
 
 # 16-bit wireless PCMCIA client drivers
@@ -25,5 +26,3 @@ obj-$(CONFIG_USB_NET_RNDIS_WLAN)	+= rndis_wlan.o
 obj-$(CONFIG_ATH_CARDS)		+= ath/
 
 obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
-
-obj-$(CONFIG_WL_TI)	+= ti/
diff --git a/drivers/net/wireless/ti/Kconfig b/drivers/net/wireless/ti/Kconfig
index cbe1e7fef61b..92fbd6597e34 100644
--- a/drivers/net/wireless/ti/Kconfig
+++ b/drivers/net/wireless/ti/Kconfig
@@ -1,11 +1,15 @@
-menuconfig WL_TI
-	bool "TI Wireless LAN support"
+config WLAN_VENDOR_TI
+	bool "Texas Instrument devices"
+	default y
 	---help---
-	  This section contains support for all the wireless drivers
-	  for Texas Instruments WLAN chips, such as wl1251 and the wl12xx
-	  family.
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
 
-if WL_TI
+if WLAN_VENDOR_TI
 source "drivers/net/wireless/ti/wl1251/Kconfig"
 source "drivers/net/wireless/ti/wl12xx/Kconfig"
 source "drivers/net/wireless/ti/wl18xx/Kconfig"
@@ -21,4 +25,4 @@ config WILINK_PLATFORM_DATA
 	Small platform data bit needed to pass data to the sdio modules.
 
 
-endif # WL_TI
+endif # WLAN_VENDOR_TI
diff --git a/drivers/net/wireless/ti/wl1251/Kconfig b/drivers/net/wireless/ti/wl1251/Kconfig
index 477a206c098e..7142ccf3a425 100644
--- a/drivers/net/wireless/ti/wl1251/Kconfig
+++ b/drivers/net/wireless/ti/wl1251/Kconfig
@@ -1,4 +1,4 @@
-menuconfig WL1251
+config WL1251
 	tristate "TI wl1251 driver support"
 	depends on MAC80211
 	select FW_LOADER
diff --git a/drivers/net/wireless/ti/wlcore/Kconfig b/drivers/net/wireless/ti/wlcore/Kconfig
index 7c099542b214..969c9d79bfc8 100644
--- a/drivers/net/wireless/ti/wlcore/Kconfig
+++ b/drivers/net/wireless/ti/wlcore/Kconfig
@@ -1,6 +1,6 @@
 config WLCORE
 	tristate "TI wlcore support"
-	depends on WL_TI && MAC80211
+	depends on MAC80211
 	select FW_LOADER
 	---help---
 	  This module contains the main code for TI WLAN chips.  It abstracts
-- 
1.7.9.5
