From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [RFC/RFT 27/27] rtlwifi: rtl8188ee: Enable build of new driver
Date: Mon, 25 Feb 2013 18:13:39 -0600
Message-ID: <1361837619-2985-28-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jcheung-IBi9RG/b67k@public.gmane.org, machen-IBi9RG/b67k@public.gmane.org,
	mmarek-AlSwsSmVLrQ@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These changes enable building the new driver.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: jcheung-IBi9RG/b67k@public.gmane.org
Cc: machen-IBi9RG/b67k@public.gmane.org
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org
---
 drivers/net/wireless/rtlwifi/Kconfig            | 11 +++++++++++
 drivers/net/wireless/rtlwifi/Makefile           |  1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile | 16 ++++++++++++++++
 3 files changed, 28 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index b6aa0c4..e42b3a8 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -55,6 +55,17 @@ config RTL8723AE
 
 	If you choose to build it as a module, it will be called rtl8723ae
 
+config RTL8188EE
+	tristate "Realtek RTL8188EE Wireless Network Adapter"
+	depends on MAC80211 && PCI
+	select FW_LOADER
+	select RTLWIFI
+	---help---
+	This is the driver for Realtek RTL8188EE 802.11n PCIe
+	wireless network adapters.
+
+	If you choose to build it as a module, it will be called rtl8188ee
+
 config RTL8192CU
 	tristate "Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter"
 	depends on RTLWIFI && USB
diff --git a/drivers/net/wireless/rtlwifi/Makefile b/drivers/net/wireless/rtlwifi/Makefile
index 3b1cbac..ff02b87 100644
--- a/drivers/net/wireless/rtlwifi/Makefile
+++ b/drivers/net/wireless/rtlwifi/Makefile
@@ -26,5 +26,6 @@ obj-$(CONFIG_RTL8192CU)		+= rtl8192cu/
 obj-$(CONFIG_RTL8192SE)		+= rtl8192se/
 obj-$(CONFIG_RTL8192DE)		+= rtl8192de/
 obj-$(CONFIG_RTL8723AE)		+= rtl8723ae/
+obj-$(CONFIG_RTL8188EE)		+= rtl8188ee/
 
 ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile b/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
new file mode 100644
index 0000000..f3772c9
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
@@ -0,0 +1,16 @@
+rtl8188ee-objs :=		\
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
+		trx.o
+
+obj-$(CONFIG_RTL8188EE) += rtl8188ee.o
+
+ccflags-y += -D__CHECK_ENDIAN__
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
