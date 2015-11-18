From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 26/27] ath: unify Kconfig with other vendors
Date: Wed, 18 Nov 2015 16:46:05 +0200
Message-ID: <1447857966-19560-27-git-send-email-kvalo@codeaurora.org>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change menuconfig to config to keep the Kconfig entries unified. Part of
reorganising wireless drivers directory and Kconfig.

Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
---
 drivers/net/wireless/Kconfig     |    3 +--
 drivers/net/wireless/Makefile    |    3 +--
 drivers/net/wireless/ath/Kconfig |   17 ++++++++++-------
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index cb115db309ce..3af6d0b9ca21 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -18,6 +18,7 @@ menuconfig WLAN
 if WLAN
 
 source "drivers/net/wireless/admtek/Kconfig"
+source "drivers/net/wireless/ath/Kconfig"
 source "drivers/net/wireless/atmel/Kconfig"
 source "drivers/net/wireless/broadcom/Kconfig"
 source "drivers/net/wireless/cisco/Kconfig"
@@ -99,6 +100,4 @@ config MAC80211_HWSIM
 	  To compile this driver as a module, choose M here: the module will be
 	  called mac80211_hwsim.  If unsure, say N.
 
-source "drivers/net/wireless/ath/Kconfig"
-
 endif # WLAN
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 8c99b9faab09..f00d42953fb8 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -3,6 +3,7 @@
 #
 
 obj-$(CONFIG_WLAN_VENDOR_ADMTEK) += admtek/
+obj-$(CONFIG_WLAN_VENDOR_ATH) += ath/
 obj-$(CONFIG_WLAN_VENDOR_ATMEL) += atmel/
 obj-$(CONFIG_WLAN_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
@@ -23,6 +24,4 @@ obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
 
 obj-$(CONFIG_USB_NET_RNDIS_WLAN)	+= rndis_wlan.o
 
-obj-$(CONFIG_ATH_CARDS)		+= ath/
-
 obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
diff --git a/drivers/net/wireless/ath/Kconfig b/drivers/net/wireless/ath/Kconfig
index ce7826009eeb..44b2470af81d 100644
--- a/drivers/net/wireless/ath/Kconfig
+++ b/drivers/net/wireless/ath/Kconfig
@@ -1,13 +1,16 @@
 config ATH_COMMON
 	tristate
 
-menuconfig ATH_CARDS
-	tristate "Atheros Wireless Cards"
-	depends on CFG80211 && (!UML || BROKEN)
+config WLAN_VENDOR_ATH
+	bool "Atheros/Qualcomm devices"
+	default y
 	---help---
-	  This will enable the support for the Atheros wireless drivers.
-	  ath5k, ath9k, ath9k_htc and ar9170 drivers share some common code, this option
-	  enables the common ath.ko module which shares common helpers.
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
 
 	  For more information and documentation on this module you can visit:
 
@@ -17,7 +20,7 @@ menuconfig ATH_CARDS
 
 	  http://wireless.kernel.org/en/users/Drivers/Atheros
 
-if ATH_CARDS
+if WLAN_VENDOR_ATH
 
 config ATH_DEBUG
 	bool "Atheros wireless debugging"
-- 
1.7.9.5
