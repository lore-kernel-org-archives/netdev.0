From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 20/27] prism54: move under intersil vendor directory
Date: Wed, 18 Nov 2015 16:45:59 +0200
Message-ID: <1447857966-19560-21-git-send-email-kvalo@codeaurora.org>
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
 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/Kconfig                       |   20 --------------------
 drivers/net/wireless/Makefile                      |    2 --
 drivers/net/wireless/intersil/Kconfig              |   20 ++++++++++++++++++++
 drivers/net/wireless/intersil/Makefile             |    1 +
 .../net/wireless/{ => intersil}/prism54/Makefile   |    0
 .../net/wireless/{ => intersil}/prism54/isl_38xx.c |    0
 .../net/wireless/{ => intersil}/prism54/isl_38xx.h |    0
 .../wireless/{ => intersil}/prism54/isl_ioctl.c    |    0
 .../wireless/{ => intersil}/prism54/isl_ioctl.h    |    0
 .../net/wireless/{ => intersil}/prism54/isl_oid.h  |    0
 .../wireless/{ => intersil}/prism54/islpci_dev.c   |    0
 .../wireless/{ => intersil}/prism54/islpci_dev.h   |    0
 .../wireless/{ => intersil}/prism54/islpci_eth.c   |    0
 .../wireless/{ => intersil}/prism54/islpci_eth.h   |    0
 .../{ => intersil}/prism54/islpci_hotplug.c        |    0
 .../wireless/{ => intersil}/prism54/islpci_mgt.c   |    0
 .../wireless/{ => intersil}/prism54/islpci_mgt.h   |    0
 .../net/wireless/{ => intersil}/prism54/oid_mgt.c  |    0
 .../net/wireless/{ => intersil}/prism54/oid_mgt.h  |    0
 .../wireless/{ => intersil}/prism54/prismcompat.h  |    0
 21 files changed, 22 insertions(+), 23 deletions(-)
 rename drivers/net/wireless/{ => intersil}/prism54/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_38xx.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_38xx.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_ioctl.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_ioctl.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_oid.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_dev.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_dev.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_eth.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_eth.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_hotplug.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_mgt.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_mgt.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/oid_mgt.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/oid_mgt.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/prismcompat.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 53c15af0d967..2c41981e4fdd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8498,7 +8498,7 @@ M:	"Luis R. Rodriguez" <mcgrof@gmail.com>
 L:	linux-wireless@vger.kernel.org
 W:	http://wireless.kernel.org/en/users/Drivers/p54
 S:	Obsolete
-F:	drivers/net/wireless/prism54/
+F:	drivers/net/wireless/intersil/prism54/
 
 PS3 NETWORK SUPPORT
 M:	Geoff Levand <geoff@infradead.org>
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index cc1f168603dc..c92671f8b1c6 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -52,26 +52,6 @@ config PCMCIA_WL3501
 	  It has basic support for Linux wireless extensions and initial
 	  micro support for ethtool.
 
-config PRISM54
-	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus (DEPRECATED)'
-	depends on PCI
-	select WIRELESS_EXT
-	select WEXT_SPY
-	select WEXT_PRIV
-	select FW_LOADER
-	---help---
-	  This enables support for FullMAC PCI/Cardbus prism54 devices. This
-	  driver is now deprecated in favor for the SoftMAC driver, p54pci.
-	  p54pci supports FullMAC PCI/Cardbus devices as well.
-
-	  For more information refer to the p54 wiki:
-
-	  http://wireless.kernel.org/en/users/Drivers/p54
-
-	  Note: You need a motherboard with DMA support to use any of these cards
-
-	  When built as module you get the module prism54
-
 config USB_NET_RNDIS_WLAN
 	tristate "Wireless RNDIS USB support"
 	depends on USB
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index dd6d17cc4b7e..679a1a0a048d 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -12,8 +12,6 @@ obj-$(CONFIG_WLAN_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_WLAN_VENDOR_ST) += st/
 obj-$(CONFIG_WLAN_VENDOR_ZYDAS) += zydas/
 
-obj-$(CONFIG_PRISM54)		+= prism54/
-
 obj-$(CONFIG_WLAN)		+= realtek/
 
 # 16-bit wireless PCMCIA client drivers
diff --git a/drivers/net/wireless/intersil/Kconfig b/drivers/net/wireless/intersil/Kconfig
index 2b056b6daef8..9da136049955 100644
--- a/drivers/net/wireless/intersil/Kconfig
+++ b/drivers/net/wireless/intersil/Kconfig
@@ -15,4 +15,24 @@ source "drivers/net/wireless/intersil/hostap/Kconfig"
 source "drivers/net/wireless/intersil/orinoco/Kconfig"
 source "drivers/net/wireless/intersil/p54/Kconfig"
 
+config PRISM54
+	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus (DEPRECATED)'
+	depends on PCI
+	select WIRELESS_EXT
+	select WEXT_SPY
+	select WEXT_PRIV
+	select FW_LOADER
+	---help---
+	  This enables support for FullMAC PCI/Cardbus prism54 devices. This
+	  driver is now deprecated in favor for the SoftMAC driver, p54pci.
+	  p54pci supports FullMAC PCI/Cardbus devices as well.
+
+	  For more information refer to the p54 wiki:
+
+	  http://wireless.kernel.org/en/users/Drivers/p54
+
+	  Note: You need a motherboard with DMA support to use any of these cards
+
+	  When built as module you get the module prism54
+
 endif # WLAN_VENDOR_INTERSIL
diff --git a/drivers/net/wireless/intersil/Makefile b/drivers/net/wireless/intersil/Makefile
index aedb713da746..9a8cbfee3ea5 100644
--- a/drivers/net/wireless/intersil/Makefile
+++ b/drivers/net/wireless/intersil/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_HOSTAP)		+= hostap/
 obj-$(CONFIG_HERMES)		+= orinoco/
 obj-$(CONFIG_P54_COMMON)	+= p54/
+obj-$(CONFIG_PRISM54)		+= prism54/
diff --git a/drivers/net/wireless/prism54/Makefile b/drivers/net/wireless/intersil/prism54/Makefile
similarity index 100%
rename from drivers/net/wireless/prism54/Makefile
rename to drivers/net/wireless/intersil/prism54/Makefile
diff --git a/drivers/net/wireless/prism54/isl_38xx.c b/drivers/net/wireless/intersil/prism54/isl_38xx.c
similarity index 100%
rename from drivers/net/wireless/prism54/isl_38xx.c
rename to drivers/net/wireless/intersil/prism54/isl_38xx.c
diff --git a/drivers/net/wireless/prism54/isl_38xx.h b/drivers/net/wireless/intersil/prism54/isl_38xx.h
similarity index 100%
rename from drivers/net/wireless/prism54/isl_38xx.h
rename to drivers/net/wireless/intersil/prism54/isl_38xx.h
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/intersil/prism54/isl_ioctl.c
similarity index 100%
rename from drivers/net/wireless/prism54/isl_ioctl.c
rename to drivers/net/wireless/intersil/prism54/isl_ioctl.c
diff --git a/drivers/net/wireless/prism54/isl_ioctl.h b/drivers/net/wireless/intersil/prism54/isl_ioctl.h
similarity index 100%
rename from drivers/net/wireless/prism54/isl_ioctl.h
rename to drivers/net/wireless/intersil/prism54/isl_ioctl.h
diff --git a/drivers/net/wireless/prism54/isl_oid.h b/drivers/net/wireless/intersil/prism54/isl_oid.h
similarity index 100%
rename from drivers/net/wireless/prism54/isl_oid.h
rename to drivers/net/wireless/intersil/prism54/isl_oid.h
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/intersil/prism54/islpci_dev.c
similarity index 100%
rename from drivers/net/wireless/prism54/islpci_dev.c
rename to drivers/net/wireless/intersil/prism54/islpci_dev.c
diff --git a/drivers/net/wireless/prism54/islpci_dev.h b/drivers/net/wireless/intersil/prism54/islpci_dev.h
similarity index 100%
rename from drivers/net/wireless/prism54/islpci_dev.h
rename to drivers/net/wireless/intersil/prism54/islpci_dev.h
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/intersil/prism54/islpci_eth.c
similarity index 100%
rename from drivers/net/wireless/prism54/islpci_eth.c
rename to drivers/net/wireless/intersil/prism54/islpci_eth.c
diff --git a/drivers/net/wireless/prism54/islpci_eth.h b/drivers/net/wireless/intersil/prism54/islpci_eth.h
similarity index 100%
rename from drivers/net/wireless/prism54/islpci_eth.h
rename to drivers/net/wireless/intersil/prism54/islpci_eth.h
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/intersil/prism54/islpci_hotplug.c
similarity index 100%
rename from drivers/net/wireless/prism54/islpci_hotplug.c
rename to drivers/net/wireless/intersil/prism54/islpci_hotplug.c
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/intersil/prism54/islpci_mgt.c
similarity index 100%
rename from drivers/net/wireless/prism54/islpci_mgt.c
rename to drivers/net/wireless/intersil/prism54/islpci_mgt.c
diff --git a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wireless/intersil/prism54/islpci_mgt.h
similarity index 100%
rename from drivers/net/wireless/prism54/islpci_mgt.h
rename to drivers/net/wireless/intersil/prism54/islpci_mgt.h
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/intersil/prism54/oid_mgt.c
similarity index 100%
rename from drivers/net/wireless/prism54/oid_mgt.c
rename to drivers/net/wireless/intersil/prism54/oid_mgt.c
diff --git a/drivers/net/wireless/prism54/oid_mgt.h b/drivers/net/wireless/intersil/prism54/oid_mgt.h
similarity index 100%
rename from drivers/net/wireless/prism54/oid_mgt.h
rename to drivers/net/wireless/intersil/prism54/oid_mgt.h
diff --git a/drivers/net/wireless/prism54/prismcompat.h b/drivers/net/wireless/intersil/prism54/prismcompat.h
similarity index 100%
rename from drivers/net/wireless/prism54/prismcompat.h
rename to drivers/net/wireless/intersil/prism54/prismcompat.h
-- 
1.7.9.5
