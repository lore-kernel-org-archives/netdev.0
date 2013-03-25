From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 25/25] rtlwifi: rtl8188ee: Enable build of new driver
Date: Sun, 24 Mar 2013 22:06:57 -0500
Message-ID: <1364180817-8028-26-git-send-email-Larry.Finger@lwfinger.net>
References: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz, zhiyuan_yang@realsil.com.cn, page_he@realsil.com.cn
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:52456 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468Ab3CYDHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:07:55 -0400
In-Reply-To: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes enable building the new driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
Cc: zhiyuan_yang@realsil.com.cn
Cc: page_he@realsil.com.cn
---
 drivers/net/wireless/rtlwifi/Kconfig            |  9 +++++++++
 drivers/net/wireless/rtlwifi/Makefile           |  1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile | 16 ++++++++++++++++
 3 files changed, 26 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index b6aa0c4..7253de3 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -55,6 +55,15 @@ config RTL8723AE
 
 	If you choose to build it as a module, it will be called rtl8723ae
 
+config RTL8188EE
+	tristate "Realtek RTL8188EE Wireless Network Adapter"
+	depends on RTLWIFI && PCI
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
index 0000000..01173a2
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
+ccflags-y += -I drivers/net/wireless/rtlwifi -D__CHECK_ENDIAN__
-- 
1.8.1.4
