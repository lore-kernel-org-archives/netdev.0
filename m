From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 27/29] i2400m: Makefile and Kconfig
Date: Mon, 15 Dec 2008 04:58:22 -0800
Message-ID: <92be647b94e54543cb4748254dd812d3a92bfc99.1229345780.git.inaky@linux.intel.com>
References: <cover.1229345769.git.inaky@linux.intel.com>
Cc: greg@kroah.com, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1229345769.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Integrate the i2400m driver into the kernel's build and Kconfig.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/Kconfig               |    2 +
 drivers/net/Makefile              |    1 +
 drivers/net/wimax/Kconfig         |   17 +++++++++++++
 drivers/net/wimax/Makefile        |    2 +
 drivers/net/wimax/i2400m/Kconfig  |   49 +++++++++++++++++++++++++++++++++++++
 drivers/net/wimax/i2400m/Makefile |   29 ++++++++++++++++++++++
 6 files changed, 100 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/Kconfig
 create mode 100644 drivers/net/wimax/Makefile
 create mode 100644 drivers/net/wimax/i2400m/Kconfig
 create mode 100644 drivers/net/wimax/i2400m/Makefile

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 231eeaf..6255b79 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2585,6 +2585,8 @@ source "drivers/net/tokenring/Kconfig"
 
 source "drivers/net/wireless/Kconfig"
 
+source "drivers/net/wimax/Kconfig"
+
 source "drivers/net/usb/Kconfig"
 
 source "drivers/net/pcmcia/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f19acf8..3ac378f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -262,3 +262,4 @@ obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
 
+obj-y += wimax/
diff --git a/drivers/net/wimax/Kconfig b/drivers/net/wimax/Kconfig
new file mode 100644
index 0000000..30347e4
--- /dev/null
+++ b/drivers/net/wimax/Kconfig
@@ -0,0 +1,17 @@
+#
+# WiMAX LAN device drivers configuration
+#
+
+
+comment "Enable WiMAX (Networking options) to see the WiMAX drivers"
+        depends on WIMAX = n
+
+if WIMAX
+
+menu "WiMAX Wireless Broadband devices"
+
+source "drivers/net/wimax/i2400m/Kconfig"
+
+endmenu
+
+endif
diff --git a/drivers/net/wimax/Makefile b/drivers/net/wimax/Makefile
new file mode 100644
index 0000000..bda9430
--- /dev/null
+++ b/drivers/net/wimax/Makefile
@@ -0,0 +1,2 @@
+
+obj-$(CONFIG_WIMAX_I2400M)	+= i2400m/
diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
new file mode 100644
index 0000000..e977c46
--- /dev/null
+++ b/drivers/net/wimax/i2400m/Kconfig
@@ -0,0 +1,49 @@
+
+config WIMAX_I2400M
+        tristate
+	depends on WIMAX
+        select FW_LOADER
+
+comment "Enable USB support to see WiMAX USB drivers"
+        depends on USB = n
+
+comment "Enable MMC support to see WiMAX SDIO drivers"
+        depends on MMC = n
+
+config WIMAX_I2400M_USB
+	tristate "Intel Wireless WiMAX Connection 2400 over USB (including 5x50)"
+	depends on WIMAX && USB
+        select WIMAX_I2400M
+	help
+	  Select if you have a device based on the Intel WiMAX
+	  Connection 2400 over USB (like any of the Intel Wireless
+	  WiMAX/WiFi Link 5x50 series).
+
+          If unsure, it is safe to select M (module).
+
+config WIMAX_I2400M_SDIO
+	tristate "Intel Wireless WiMAX Connection 2400 over SDIO"
+	depends on WIMAX && MMC
+        select WIMAX_I2400M
+	help
+	  Select if you have a device based on the Intel WiMAX
+          Connection 2400 over SDIO.
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
index 0000000..2e8c15b
--- /dev/null
+++ b/drivers/net/wimax/i2400m/Makefile
@@ -0,0 +1,29 @@
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
+	netdev.o	\
+	tx.o		\
+	rx.o
+
+i2400m-$(CONFIG_DEBUG_FS) += debugfs.o
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
