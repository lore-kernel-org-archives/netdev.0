From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 02/27] airo: move under cisco vendor directory
Date: Wed, 18 Nov 2015 16:45:41 +0200
Message-ID: <1447857966-19560-3-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/Kconfig               |   43 +--------------------
 drivers/net/wireless/Makefile              |    4 +-
 drivers/net/wireless/cisco/Kconfig         |   56 ++++++++++++++++++++++++++++
 drivers/net/wireless/cisco/Makefile        |    2 +
 drivers/net/wireless/{ => cisco}/airo.c    |    0
 drivers/net/wireless/{ => cisco}/airo.h    |    0
 drivers/net/wireless/{ => cisco}/airo_cs.c |    0
 7 files changed, 60 insertions(+), 45 deletions(-)
 create mode 100644 drivers/net/wireless/cisco/Kconfig
 create mode 100644 drivers/net/wireless/cisco/Makefile
 rename drivers/net/wireless/{ => cisco}/airo.c (100%)
 rename drivers/net/wireless/{ => cisco}/airo.h (100%)
 rename drivers/net/wireless/{ => cisco}/airo_cs.c (100%)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 7d8f47117c4d..ce5211ba1b29 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -18,6 +18,7 @@ menuconfig WLAN
 if WLAN
 
 source "drivers/net/wireless/admtek/Kconfig"
+source "drivers/net/wireless/cisco/Kconfig"
 
 config PCMCIA_RAYCS
 	tristate "Aviator/Raytheon 2.4GHz wireless support"
@@ -53,26 +54,6 @@ config LIBERTAS_THINFIRM_USB
 	---help---
 	  A driver for Marvell Libertas 8388 USB devices using thinfirm.
 
-config AIRO
-	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
-	depends on CFG80211 && ISA_DMA_API && (PCI || BROKEN)
-	select WIRELESS_EXT
-	select CRYPTO
-	select WEXT_SPY
-	select WEXT_PRIV
-	---help---
-	  This is the standard Linux driver to support Cisco/Aironet ISA and
-	  PCI 802.11 wireless cards.
-	  It supports the new 802.11b cards from Cisco (Cisco 34X, Cisco 35X
-	  - with or without encryption) as well as card before the Cisco
-	  acquisition (Aironet 4500, Aironet 4800, Aironet 4800B).
-
-	  This driver support both the standard Linux Wireless Extensions
-	  and Cisco proprietary API, so both the Linux Wireless Tools and the
-	  Cisco Linux utilities can be used to configure the card.
-
-	  The driver can be compiled as a module and will be named "airo".
-
 config ATMEL
       tristate "Atmel at76c50x chipset  802.11b support"
       depends on CFG80211 && (PCI || PCMCIA)
@@ -116,28 +97,6 @@ config AT76C50X_USB
           Enable support for USB Wireless devices using Atmel at76c503,
           at76c505 or at76c505a chips.
 
-config AIRO_CS
-	tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
-	depends on CFG80211 && PCMCIA && (BROKEN || !M32R)
-	select WIRELESS_EXT
-	select WEXT_SPY
-	select WEXT_PRIV
-	select CRYPTO
-	select CRYPTO_AES
-	---help---
-	  This is the standard Linux driver to support Cisco/Aironet PCMCIA
-	  802.11 wireless cards.  This driver is the same as the Aironet
-	  driver part of the Linux Pcmcia package.
-	  It supports the new 802.11b cards from Cisco (Cisco 34X, Cisco 35X
-	  - with or without encryption) as well as card before the Cisco
-	  acquisition (Aironet 4500, Aironet 4800, Aironet 4800B). It also
-	  supports OEM of Cisco such as the DELL TrueMobile 4800 and Xircom
-	  802.11b cards.
-
-	  This driver support both the standard Linux Wireless Extensions
-	  and Cisco proprietary API, so both the Linux Wireless Tools and the
-	  Cisco Linux utilities can be used to configure the card.
-
 config PCMCIA_WL3501
 	tristate "Planet WL3501 PCMCIA cards"
 	depends on CFG80211 && PCMCIA
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index be215f43ec1d..853294d84fa9 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -3,15 +3,13 @@
 #
 
 obj-$(CONFIG_WLAN_VENDOR_ADMTEK) += admtek/
+obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 
 obj-$(CONFIG_IPW2100) += ipw2x00/
 obj-$(CONFIG_IPW2200) += ipw2x00/
 
 obj-$(CONFIG_HERMES)		+= orinoco/
 
-obj-$(CONFIG_AIRO)		+= airo.o
-obj-$(CONFIG_AIRO_CS)		+= airo_cs.o airo.o
-
 obj-$(CONFIG_ATMEL)             += atmel.o
 obj-$(CONFIG_PCI_ATMEL)         += atmel_pci.o 
 obj-$(CONFIG_PCMCIA_ATMEL)      += atmel_cs.o
diff --git a/drivers/net/wireless/cisco/Kconfig b/drivers/net/wireless/cisco/Kconfig
new file mode 100644
index 000000000000..b22567dff893
--- /dev/null
+++ b/drivers/net/wireless/cisco/Kconfig
@@ -0,0 +1,56 @@
+config WLAN_VENDOR_CISCO
+	bool "Cisco devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_CISCO
+
+config AIRO
+	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
+	depends on CFG80211 && ISA_DMA_API && (PCI || BROKEN)
+	select WIRELESS_EXT
+	select CRYPTO
+	select WEXT_SPY
+	select WEXT_PRIV
+	---help---
+	  This is the standard Linux driver to support Cisco/Aironet ISA and
+	  PCI 802.11 wireless cards.
+	  It supports the new 802.11b cards from Cisco (Cisco 34X, Cisco 35X
+	  - with or without encryption) as well as card before the Cisco
+	  acquisition (Aironet 4500, Aironet 4800, Aironet 4800B).
+
+	  This driver support both the standard Linux Wireless Extensions
+	  and Cisco proprietary API, so both the Linux Wireless Tools and the
+	  Cisco Linux utilities can be used to configure the card.
+
+	  The driver can be compiled as a module and will be named "airo".
+
+config AIRO_CS
+	tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
+	depends on CFG80211 && PCMCIA && (BROKEN || !M32R)
+	select WIRELESS_EXT
+	select WEXT_SPY
+	select WEXT_PRIV
+	select CRYPTO
+	select CRYPTO_AES
+	---help---
+	  This is the standard Linux driver to support Cisco/Aironet PCMCIA
+	  802.11 wireless cards.  This driver is the same as the Aironet
+	  driver part of the Linux Pcmcia package.
+	  It supports the new 802.11b cards from Cisco (Cisco 34X, Cisco 35X
+	  - with or without encryption) as well as card before the Cisco
+	  acquisition (Aironet 4500, Aironet 4800, Aironet 4800B). It also
+	  supports OEM of Cisco such as the DELL TrueMobile 4800 and Xircom
+	  802.11b cards.
+
+	  This driver support both the standard Linux Wireless Extensions
+	  and Cisco proprietary API, so both the Linux Wireless Tools and the
+	  Cisco Linux utilities can be used to configure the card.
+
+endif # WLAN_VENDOR_CISCO
diff --git a/drivers/net/wireless/cisco/Makefile b/drivers/net/wireless/cisco/Makefile
new file mode 100644
index 000000000000..d4110b19d6ef
--- /dev/null
+++ b/drivers/net/wireless/cisco/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_AIRO)		+= airo.o
+obj-$(CONFIG_AIRO_CS)		+= airo_cs.o airo.o
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/cisco/airo.c
similarity index 100%
rename from drivers/net/wireless/airo.c
rename to drivers/net/wireless/cisco/airo.c
diff --git a/drivers/net/wireless/airo.h b/drivers/net/wireless/cisco/airo.h
similarity index 100%
rename from drivers/net/wireless/airo.h
rename to drivers/net/wireless/cisco/airo.h
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/cisco/airo_cs.c
similarity index 100%
rename from drivers/net/wireless/airo_cs.c
rename to drivers/net/wireless/cisco/airo_cs.c
-- 
1.7.9.5
