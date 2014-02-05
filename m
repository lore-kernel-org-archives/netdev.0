From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 16/16] rtlwifi: rtl8723be: Turn on building of new driver
Date: Wed,  5 Feb 2014 13:55:00 -0600
Message-ID: <1391630100-13504-17-git-send-email-Larry.Finger@lwfinger.net>
References: <1391630100-13504-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391630100-13504-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

All code for the new driver was previously committed and it is now
possible to build the new driver.

A duplicate line for the Kconfig section for the rtl8723ae was removed
in this commit

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/Kconfig            | 19 ++++++++++++++++---
 drivers/net/wireless/rtlwifi/Makefile           |  1 +
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile | 20 ++++++++++++++++++++
 3 files changed, 37 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/Makefile

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index 9251e0d..bf3cf12 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -5,7 +5,7 @@ menuconfig RTL_CARDS
 	---help---
 	  This option will enable support for the Realtek mac80211-based
 	  wireless drivers. Drivers rtl8192ce, rtl8192cu, rtl8192se, rtl8192de,
-	  rtl8723ae, and rtl8188ae share some common code.
+	  rtl8723ae, rtl8723be, and rtl8188ae share some common code.
 
 if RTL_CARDS
 
@@ -56,6 +56,19 @@ config RTL8723AE
 
 	If you choose to build it as a module, it will be called rtl8723ae
 
+config RTL8723BE
+	tristate "Realtek RTL8723BE PCIe Wireless Network Adapter"
+	depends on PCI
+	select RTLWIFI
+	select RTLWIFI_PCI
+	select RTL8723_COMMON
+	select RTLBTCOEXIST
+	---help---
+	This is the driver for Realtek RTL8723BE 802.11n PCIe
+	wireless network adapters.
+
+	If you choose to build it as a module, it will be called rtl8723be
+
 config RTL8188EE
 	tristate "Realtek RTL8188EE Wireless Network Adapter"
 	depends on PCI
@@ -105,12 +118,12 @@ config RTL8192C_COMMON
 
 config RTL8723_COMMON
 	tristate
-	depends on RTL8723AE
+	depends on RTL8723AE || RTL8723BE
 	default y
 
 config RTLBTCOEXIST
 	tristate
-	depends on RTL8723AE
+	depends on RTL8723AE || RTL8723BE
 	default y
 
 endif
diff --git a/drivers/net/wireless/rtlwifi/Makefile b/drivers/net/wireless/rtlwifi/Makefile
index d97d1b9..bba36a0 100644
--- a/drivers/net/wireless/rtlwifi/Makefile
+++ b/drivers/net/wireless/rtlwifi/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_RTL8192CU)		+= rtl8192cu/
 obj-$(CONFIG_RTL8192SE)		+= rtl8192se/
 obj-$(CONFIG_RTL8192DE)		+= rtl8192de/
 obj-$(CONFIG_RTL8723AE)		+= rtl8723ae/
+obj-$(CONFIG_RTL8723BE)		+= rtl8723be/
 obj-$(CONFIG_RTL8188EE)		+= rtl8188ee/
 obj-$(CONFIG_RTLBTCOEXIST)	+= btcoexist/
 obj-$(CONFIG_RTL8723_COMMON)	+= rtl8723com/
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/Makefile b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
new file mode 100644
index 0000000..4a75aab
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
@@ -0,0 +1,20 @@
+obj-m := rtl8723be.o
+
+
+rtl8723be-objs :=		\
+		dm.o		\
+		fw.o		\
+		hw.o		\
+		led.o		\
+		phy.o		\
+		pwrseq.o	\
+		pwrseqcmd.o	\
+		rf.o		\
+		sw.o		\
+		table.o		\
+		trx.o		\
+
+
+obj-$(CONFIG_RTL8723BE) += rtl8723be.o
+
+ccflags-y += -D__CHECK_ENDIAN__
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
