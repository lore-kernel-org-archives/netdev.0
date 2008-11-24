From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 37/39] i2400m: Makefile and Kconfig
Date: Mon, 24 Nov 2008 13:51:00 -0800
Message-ID: <39be706ca76281a81636be32de15cb214af71a51.1227562829.git.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:13165 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753225AbYKXVvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:51:53 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides the Makefile and KConfig for the i2400m driver,
integrating them into the WiMAX stack's Makefile and Kconfig.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/Kconfig         |    5 ++++
 drivers/net/wimax/Makefile        |    1 +
 drivers/net/wimax/i2400m/Kconfig  |   49 +++++++++++++++++++++++++++++++++++++
 drivers/net/wimax/i2400m/Makefile |   28 +++++++++++++++++++++
 4 files changed, 83 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/i2400m/Kconfig
 create mode 100644 drivers/net/wimax/i2400m/Makefile

diff --git a/drivers/net/wimax/Kconfig b/drivers/net/wimax/Kconfig
index 98d4c27..cdd845c 100644
--- a/drivers/net/wimax/Kconfig
+++ b/drivers/net/wimax/Kconfig
@@ -31,3 +31,8 @@ config WIMAX_DEBUG_LEVEL
 
          It is recommended that it is left at 8.
 
+if WIMAX
+
+source "drivers/net/wimax/i2400m/Kconfig"
+
+endif
diff --git a/drivers/net/wimax/Makefile b/drivers/net/wimax/Makefile
index 22d5a28..a199447 100644
--- a/drivers/net/wimax/Makefile
+++ b/drivers/net/wimax/Makefile
@@ -1,4 +1,5 @@
 
+obj-$(CONFIG_WIMAX_I2400M)	+= i2400m/
 obj-$(CONFIG_WIMAX)		+= wimax.o
 
 wimax-objs :=		\
diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
new file mode 100644
index 0000000..3f582a9
--- /dev/null
+++ b/drivers/net/wimax/i2400m/Kconfig
@@ -0,0 +1,49 @@
+
+config WIMAX_I2400M
+        tristate
+	depends on WIMAX
+        select FW_LOADER
+
+comment "Enable USB support to see USB drivers"
+        depends on !USB
+
+comment "Enable MMC support to see SDIO drivers"
+        depends on !MMC
+
+config WIMAX_I2400M_USB
+	tristate "Support for Intel Wireless WiMAX Connection 2400 over USB (eg: 5x50)"
+	depends on WIMAX && USB
+        select WIMAX_I2400M
+	help
+	  Select if you have a device based on the Intel WiMAX
+	  Connection 2400 over USB (like any of the Intel 5x50
+	  Wireless Wifi/WiMAX Link series).
+
+          If unsure, it is safe to select M (module).
+
+config WIMAX_I2400M_SDIO
+	tristate "Support for Intel Wireless WiMAX Connection 2400 over SDIO"
+	depends on WIMAX && MMC
+        select WIMAX_I2400M
+	help
+	  Select if you have a device based on the Intel WiMAX
+	  Connection 2400 over SDIO.
+
+          If unsure, it is safe to select M (module).
+
+config WIMAX_I2400M_DEBUG_LEVEL
+       int "WiMAX i2400m debug level"
+       depends on WIMAX_I2400M
+       default 8
+       help
+
+         Select the maximum debug verbosity level to be compiled into
+         the WiMAX i2400m driver code.
+
+         By default, this is disabled at runtime and can be
+         selectively enabled at runtime for different parts of the
+         code using the sysfs debug-levels file.
+
+         If set at zero, this will compile out all the debug code.
+
+         It is recommended that it is left at 8.
diff --git a/drivers/net/wimax/i2400m/Makefile b/drivers/net/wimax/i2400m/Makefile
new file mode 100644
index 0000000..7113a5f
--- /dev/null
+++ b/drivers/net/wimax/i2400m/Makefile
@@ -0,0 +1,28 @@
+
+obj-$(CONFIG_WIMAX_I2400M) += i2400m.o
+obj-$(CONFIG_WIMAX_I2400M_USB) += i2400m-usb.o
+obj-$(CONFIG_WIMAX_I2400M_SDIO) += i2400m-sdio.o
+
+i2400m-objs :=		\
+	control.o	\
+	driver.o	\
+	fw.o		\
+	op-rfkill.o	\
+	sysfs.o		\
+	netdev.o	\
+	tx.o		\
+	rx.o
+
+i2400m-usb-objs :=		\
+	usb-fw.o		\
+	usb-notif.o		\
+	usb-tx.o		\
+	usb-rx.o		\
+	usb.o
+
+
+i2400m-sdio-objs := 		\
+	sdio.o      		\
+	sdio-tx.o   		\
+	sdio-fw.o	 	\
+	sdio-rx.o
-- 
1.5.6.5

