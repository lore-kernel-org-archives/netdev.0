From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 03/27] atmel: move under atmel vendor directory
Date: Wed, 18 Nov 2015 16:45:42 +0200
Message-ID: <1447857966-19560-4-git-send-email-kvalo@codeaurora.org>
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
 MAINTAINERS                                     |    2 +-
 drivers/net/wireless/Kconfig                    |   44 +----------------
 drivers/net/wireless/Makefile                   |    7 +--
 drivers/net/wireless/atmel/Kconfig              |   57 +++++++++++++++++++++++
 drivers/net/wireless/atmel/Makefile             |    5 ++
 drivers/net/wireless/{ => atmel}/at76c50x-usb.c |    0
 drivers/net/wireless/{ => atmel}/at76c50x-usb.h |    0
 drivers/net/wireless/{ => atmel}/atmel.c        |    0
 drivers/net/wireless/{ => atmel}/atmel.h        |    0
 drivers/net/wireless/{ => atmel}/atmel_cs.c     |    0
 drivers/net/wireless/{ => atmel}/atmel_pci.c    |    0
 11 files changed, 65 insertions(+), 50 deletions(-)
 create mode 100644 drivers/net/wireless/atmel/Kconfig
 create mode 100644 drivers/net/wireless/atmel/Makefile
 rename drivers/net/wireless/{ => atmel}/at76c50x-usb.c (100%)
 rename drivers/net/wireless/{ => atmel}/at76c50x-usb.h (100%)
 rename drivers/net/wireless/{ => atmel}/atmel.c (100%)
 rename drivers/net/wireless/{ => atmel}/atmel.h (100%)
 rename drivers/net/wireless/{ => atmel}/atmel_cs.c (100%)
 rename drivers/net/wireless/{ => atmel}/atmel_pci.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f1adb66094f1..2f3ea01c101c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1992,7 +1992,7 @@ L:	linux-wireless@vger.kernel.org
 W:	http://www.thekelleys.org.uk/atmel
 W:	http://atmelwlandriver.sourceforge.net/
 S:	Maintained
-F:	drivers/net/wireless/atmel*
+F:	drivers/net/wireless/atmel/atmel*
 
 ATMEL MAXTOUCH DRIVER
 M:	Nick Dyer <nick.dyer@itdev.co.uk>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index ce5211ba1b29..275b6ed93f15 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -18,6 +18,7 @@ menuconfig WLAN
 if WLAN
 
 source "drivers/net/wireless/admtek/Kconfig"
+source "drivers/net/wireless/atmel/Kconfig"
 source "drivers/net/wireless/cisco/Kconfig"
 
 config PCMCIA_RAYCS
@@ -54,49 +55,6 @@ config LIBERTAS_THINFIRM_USB
 	---help---
 	  A driver for Marvell Libertas 8388 USB devices using thinfirm.
 
-config ATMEL
-      tristate "Atmel at76c50x chipset  802.11b support"
-      depends on CFG80211 && (PCI || PCMCIA)
-      select WIRELESS_EXT
-      select WEXT_PRIV
-      select FW_LOADER
-      select CRC32
-       ---help---
-        A driver 802.11b wireless cards based on the Atmel fast-vnet
-        chips. This driver supports standard Linux wireless extensions.
-
-        Many  cards based on this chipset do not have flash memory
-        and need their firmware loaded at start-up. If yours is
-        one of these, you will need to provide a firmware image
-        to be loaded into the card by the driver. The Atmel
-        firmware package can be downloaded from
-        <http://www.thekelleys.org.uk/atmel>
-
-config PCI_ATMEL
-      tristate "Atmel at76c506 PCI cards"
-      depends on ATMEL && PCI
-       ---help---
-        Enable support for PCI and mini-PCI cards containing the
-        Atmel at76c506 chip.
-
-config PCMCIA_ATMEL
-	tristate "Atmel at76c502/at76c504 PCMCIA cards"
-	depends on ATMEL && PCMCIA
-	select WIRELESS_EXT
-	select FW_LOADER
-	select CRC32
-	---help---
-	  Enable support for PCMCIA cards containing the
-	  Atmel at76c502 and at76c504 chips.
-
-config AT76C50X_USB
-        tristate "Atmel at76c503/at76c505/at76c505a USB cards"
-        depends on MAC80211 && USB
-        select FW_LOADER
-        ---help---
-          Enable support for USB Wireless devices using Atmel at76c503,
-          at76c505 or at76c505a chips.
-
 config PCMCIA_WL3501
 	tristate "Planet WL3501 PCMCIA cards"
 	depends on CFG80211 && PCMCIA
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 853294d84fa9..87eb6b2f3227 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -3,6 +3,7 @@
 #
 
 obj-$(CONFIG_WLAN_VENDOR_ADMTEK) += admtek/
+obj-$(CONFIG_WLAN_VENDOR_ATMEL) += atmel/
 obj-$(CONFIG_WLAN_VENDOR_CISCO) += cisco/
 
 obj-$(CONFIG_IPW2100) += ipw2x00/
@@ -10,12 +11,6 @@ obj-$(CONFIG_IPW2200) += ipw2x00/
 
 obj-$(CONFIG_HERMES)		+= orinoco/
 
-obj-$(CONFIG_ATMEL)             += atmel.o
-obj-$(CONFIG_PCI_ATMEL)         += atmel_pci.o 
-obj-$(CONFIG_PCMCIA_ATMEL)      += atmel_cs.o
-
-obj-$(CONFIG_AT76C50X_USB)      += at76c50x-usb.o
-
 obj-$(CONFIG_PRISM54)		+= prism54/
 
 obj-$(CONFIG_HOSTAP)		+= hostap/
diff --git a/drivers/net/wireless/atmel/Kconfig b/drivers/net/wireless/atmel/Kconfig
new file mode 100644
index 000000000000..a43cfd163254
--- /dev/null
+++ b/drivers/net/wireless/atmel/Kconfig
@@ -0,0 +1,57 @@
+config WLAN_VENDOR_ATMEL
+	bool "Atmel devices"
+	default y
+	---help---
+	  If you have a wireless card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about  cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if WLAN_VENDOR_ATMEL
+
+config ATMEL
+      tristate "Atmel at76c50x chipset  802.11b support"
+      depends on CFG80211 && (PCI || PCMCIA)
+      select WIRELESS_EXT
+      select WEXT_PRIV
+      select FW_LOADER
+      select CRC32
+       ---help---
+        A driver 802.11b wireless cards based on the Atmel fast-vnet
+        chips. This driver supports standard Linux wireless extensions.
+
+        Many  cards based on this chipset do not have flash memory
+        and need their firmware loaded at start-up. If yours is
+        one of these, you will need to provide a firmware image
+        to be loaded into the card by the driver. The Atmel
+        firmware package can be downloaded from
+        <http://www.thekelleys.org.uk/atmel>
+
+config PCI_ATMEL
+      tristate "Atmel at76c506 PCI cards"
+      depends on ATMEL && PCI
+       ---help---
+        Enable support for PCI and mini-PCI cards containing the
+        Atmel at76c506 chip.
+
+config PCMCIA_ATMEL
+	tristate "Atmel at76c502/at76c504 PCMCIA cards"
+	depends on ATMEL && PCMCIA
+	select WIRELESS_EXT
+	select FW_LOADER
+	select CRC32
+	---help---
+	  Enable support for PCMCIA cards containing the
+	  Atmel at76c502 and at76c504 chips.
+
+config AT76C50X_USB
+        tristate "Atmel at76c503/at76c505/at76c505a USB cards"
+        depends on MAC80211 && USB
+        select FW_LOADER
+        ---help---
+          Enable support for USB Wireless devices using Atmel at76c503,
+          at76c505 or at76c505a chips.
+
+endif # WLAN_VENDOR_ATMEL
diff --git a/drivers/net/wireless/atmel/Makefile b/drivers/net/wireless/atmel/Makefile
new file mode 100644
index 000000000000..e62e345f7af6
--- /dev/null
+++ b/drivers/net/wireless/atmel/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_ATMEL)             += atmel.o
+obj-$(CONFIG_PCI_ATMEL)         += atmel_pci.o 
+obj-$(CONFIG_PCMCIA_ATMEL)      += atmel_cs.o
+
+obj-$(CONFIG_AT76C50X_USB)      += at76c50x-usb.o
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/atmel/at76c50x-usb.c
similarity index 100%
rename from drivers/net/wireless/at76c50x-usb.c
rename to drivers/net/wireless/atmel/at76c50x-usb.c
diff --git a/drivers/net/wireless/at76c50x-usb.h b/drivers/net/wireless/atmel/at76c50x-usb.h
similarity index 100%
rename from drivers/net/wireless/at76c50x-usb.h
rename to drivers/net/wireless/atmel/at76c50x-usb.h
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel/atmel.c
similarity index 100%
rename from drivers/net/wireless/atmel.c
rename to drivers/net/wireless/atmel/atmel.c
diff --git a/drivers/net/wireless/atmel.h b/drivers/net/wireless/atmel/atmel.h
similarity index 100%
rename from drivers/net/wireless/atmel.h
rename to drivers/net/wireless/atmel/atmel.h
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel/atmel_cs.c
similarity index 100%
rename from drivers/net/wireless/atmel_cs.c
rename to drivers/net/wireless/atmel/atmel_cs.c
diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel/atmel_pci.c
similarity index 100%
rename from drivers/net/wireless/atmel_pci.c
rename to drivers/net/wireless/atmel/atmel_pci.c
-- 
1.7.9.5
