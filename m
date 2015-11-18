From: Kalle Valo <kvalo@codeaurora.org>
Subject: [PATCH v2 12/27] libertas_tf: move under marvell vendor directory
Date: Wed, 18 Nov 2015 16:45:51 +0200
Message-ID: <1447857966-19560-13-git-send-email-kvalo@codeaurora.org>
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
 drivers/net/wireless/Kconfig                       |   19 -------------------
 drivers/net/wireless/Makefile                      |    2 --
 drivers/net/wireless/marvell/Kconfig               |    1 +
 drivers/net/wireless/marvell/Makefile              |    2 ++
 drivers/net/wireless/marvell/libertas_tf/Kconfig   |   18 ++++++++++++++++++
 .../wireless/{ => marvell}/libertas_tf/Makefile    |    0
 .../net/wireless/{ => marvell}/libertas_tf/cmd.c   |    0
 .../wireless/{ => marvell}/libertas_tf/deb_defs.h  |    0
 .../wireless/{ => marvell}/libertas_tf/if_usb.c    |    0
 .../wireless/{ => marvell}/libertas_tf/if_usb.h    |    0
 .../{ => marvell}/libertas_tf/libertas_tf.h        |    0
 .../net/wireless/{ => marvell}/libertas_tf/main.c  |    0
 12 files changed, 21 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/wireless/marvell/libertas_tf/Kconfig
 rename drivers/net/wireless/{ => marvell}/libertas_tf/Makefile (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/deb_defs.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/if_usb.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/if_usb.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/libertas_tf.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/main.c (100%)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index b11a2d364200..25f52b32d725 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -40,25 +40,6 @@ config PCMCIA_RAYCS
 	  To compile this driver as a module, choose M here: the module will be
 	  called ray_cs.  If unsure, say N.
 
-config LIBERTAS_THINFIRM
-	tristate "Marvell 8xxx Libertas WLAN driver support with thin firmware"
-	depends on MAC80211
-	select FW_LOADER
-	---help---
-	  A library for Marvell Libertas 8xxx devices using thinfirm.
-
-config LIBERTAS_THINFIRM_DEBUG
-	bool "Enable full debugging output in the Libertas thin firmware module."
-	depends on LIBERTAS_THINFIRM
-	---help---
-	  Debugging support.
-
-config LIBERTAS_THINFIRM_USB
-	tristate "Marvell Libertas 8388 USB 802.11b/g cards with thin firmware"
-	depends on LIBERTAS_THINFIRM && USB
-	---help---
-	  A driver for Marvell Libertas 8388 USB devices using thinfirm.
-
 config PCMCIA_WL3501
 	tristate "Planet WL3501 PCMCIA cards"
 	depends on CFG80211 && PCMCIA
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index a974a6edb4b6..72b167742ac7 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -26,8 +26,6 @@ obj-$(CONFIG_USB_NET_RNDIS_WLAN)	+= rndis_wlan.o
 
 obj-$(CONFIG_USB_ZD1201)	+= zd1201.o
 
-obj-$(CONFIG_LIBERTAS_THINFIRM)	+= libertas_tf/
-
 obj-$(CONFIG_MWL8K)	+= mwl8k.o
 
 obj-$(CONFIG_RT2X00)	+= rt2x00/
diff --git a/drivers/net/wireless/marvell/Kconfig b/drivers/net/wireless/marvell/Kconfig
index 7842096bea53..97ec8f35745e 100644
--- a/drivers/net/wireless/marvell/Kconfig
+++ b/drivers/net/wireless/marvell/Kconfig
@@ -12,5 +12,6 @@ config WLAN_VENDOR_MARVELL
 if WLAN_VENDOR_MARVELL
 
 source "drivers/net/wireless/marvell/libertas/Kconfig"
+source "drivers/net/wireless/marvell/libertas_tf/Kconfig"
 
 endif # WLAN_VENDOR_MARVELL
diff --git a/drivers/net/wireless/marvell/Makefile b/drivers/net/wireless/marvell/Makefile
index 6f7ac46ded33..8f5eb423b71a 100644
--- a/drivers/net/wireless/marvell/Makefile
+++ b/drivers/net/wireless/marvell/Makefile
@@ -1 +1,3 @@
 obj-$(CONFIG_LIBERTAS)		+= libertas/
+
+obj-$(CONFIG_LIBERTAS_THINFIRM)	+= libertas_tf/
diff --git a/drivers/net/wireless/marvell/libertas_tf/Kconfig b/drivers/net/wireless/marvell/libertas_tf/Kconfig
new file mode 100644
index 000000000000..b5557af90048
--- /dev/null
+++ b/drivers/net/wireless/marvell/libertas_tf/Kconfig
@@ -0,0 +1,18 @@
+config LIBERTAS_THINFIRM
+	tristate "Marvell 8xxx Libertas WLAN driver support with thin firmware"
+	depends on MAC80211
+	select FW_LOADER
+	---help---
+	  A library for Marvell Libertas 8xxx devices using thinfirm.
+
+config LIBERTAS_THINFIRM_DEBUG
+	bool "Enable full debugging output in the Libertas thin firmware module."
+	depends on LIBERTAS_THINFIRM
+	---help---
+	  Debugging support.
+
+config LIBERTAS_THINFIRM_USB
+	tristate "Marvell Libertas 8388 USB 802.11b/g cards with thin firmware"
+	depends on LIBERTAS_THINFIRM && USB
+	---help---
+	  A driver for Marvell Libertas 8388 USB devices using thinfirm.
diff --git a/drivers/net/wireless/libertas_tf/Makefile b/drivers/net/wireless/marvell/libertas_tf/Makefile
similarity index 100%
rename from drivers/net/wireless/libertas_tf/Makefile
rename to drivers/net/wireless/marvell/libertas_tf/Makefile
diff --git a/drivers/net/wireless/libertas_tf/cmd.c b/drivers/net/wireless/marvell/libertas_tf/cmd.c
similarity index 100%
rename from drivers/net/wireless/libertas_tf/cmd.c
rename to drivers/net/wireless/marvell/libertas_tf/cmd.c
diff --git a/drivers/net/wireless/libertas_tf/deb_defs.h b/drivers/net/wireless/marvell/libertas_tf/deb_defs.h
similarity index 100%
rename from drivers/net/wireless/libertas_tf/deb_defs.h
rename to drivers/net/wireless/marvell/libertas_tf/deb_defs.h
diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/marvell/libertas_tf/if_usb.c
similarity index 100%
rename from drivers/net/wireless/libertas_tf/if_usb.c
rename to drivers/net/wireless/marvell/libertas_tf/if_usb.c
diff --git a/drivers/net/wireless/libertas_tf/if_usb.h b/drivers/net/wireless/marvell/libertas_tf/if_usb.h
similarity index 100%
rename from drivers/net/wireless/libertas_tf/if_usb.h
rename to drivers/net/wireless/marvell/libertas_tf/if_usb.h
diff --git a/drivers/net/wireless/libertas_tf/libertas_tf.h b/drivers/net/wireless/marvell/libertas_tf/libertas_tf.h
similarity index 100%
rename from drivers/net/wireless/libertas_tf/libertas_tf.h
rename to drivers/net/wireless/marvell/libertas_tf/libertas_tf.h
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/marvell/libertas_tf/main.c
similarity index 100%
rename from drivers/net/wireless/libertas_tf/main.c
rename to drivers/net/wireless/marvell/libertas_tf/main.c
-- 
1.7.9.5
