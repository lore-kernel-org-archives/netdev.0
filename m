From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/4] staging: r8192ee: Turn on build of the new driver
Date: Wed, 21 May 2014 16:25:36 -0500
Message-ID: <1400707536-3338-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, troy_tan@realsil.com.cn,
 zhangfp1@lenovo.com, Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

In addition, this commit contains a TODO file for this driver

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/Kconfig            |  2 ++
 drivers/staging/Makefile           |  1 +
 drivers/staging/rtl8192ee/Kconfig  |  8 ++++++++
 drivers/staging/rtl8192ee/Makefile | 40 ++++++++++++++++++++++++++++++++++++++
 drivers/staging/rtl8192ee/TODO     | 12 ++++++++++++
 5 files changed, 63 insertions(+)
 create mode 100644 drivers/staging/rtl8192ee/Kconfig
 create mode 100644 drivers/staging/rtl8192ee/Makefile
 create mode 100644 drivers/staging/rtl8192ee/TODO

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 0c38877..f0cf269 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -48,6 +48,8 @@ source "drivers/staging/rtl8712/Kconfig"
 
 source "drivers/staging/rtl8188eu/Kconfig"
 
+source "drivers/staging/rtl8192ee/Kconfig"
+
 source "drivers/staging/rtl8723au/Kconfig"
 
 source "drivers/staging/rtl8821ae/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 7bf91a6..f60f26f 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_RTL8192U)		+= rtl8192u/
 obj-$(CONFIG_RTL8192E)		+= rtl8192e/
 obj-$(CONFIG_R8712U)		+= rtl8712/
 obj-$(CONFIG_R8188EU)		+= rtl8188eu/
+obj-$(CONFIG_R8192EE)		+= rtl8192ee/
 obj-$(CONFIG_R8723AU)		+= rtl8723au/
 obj-$(CONFIG_R8821AE)		+= rtl8821ae/
 obj-$(CONFIG_RTS5139)		+= rts5139/
diff --git a/drivers/staging/rtl8192ee/Kconfig b/drivers/staging/rtl8192ee/Kconfig
new file mode 100644
index 0000000..92c5f44
--- /dev/null
+++ b/drivers/staging/rtl8192ee/Kconfig
@@ -0,0 +1,8 @@
+config R8192EE
+	tristate "Realtek RTL8192EE Wireless Network Adapter"
+	select FW_LOADER
+	---help---
+	This is the driver for Realtek RTL8192EE 802.11 PCIe
+	wireless network adapters.
+
+	If you choose to build it as a module, it will be called r8192ee
diff --git a/drivers/staging/rtl8192ee/Makefile b/drivers/staging/rtl8192ee/Makefile
new file mode 100644
index 0000000..3170862
--- /dev/null
+++ b/drivers/staging/rtl8192ee/Makefile
@@ -0,0 +1,40 @@
+
+PCI_MAIN_OBJS	:= base.o	\
+		cam.o	\
+		core.o	\
+		debug.o	\
+		efuse.o	\
+		pci.o	\
+		ps.o	\
+		rc.o	\
+		regd.o	\
+		stats.o
+
+PCI_8192EE_HAL_OBJS:=		\
+	rtl8192ee/dm.o		\
+	rtl8192ee/fw.o		\
+	rtl8192ee/hw.o		\
+	rtl8192ee/led.o		\
+	rtl8192ee/phy.o		\
+	rtl8192ee/pwrseq.o	\
+	rtl8192ee/pwrseqcmd.o	\
+	rtl8192ee/rf.o		\
+	rtl8192ee/sw.o		\
+	rtl8192ee/table.o	\
+	rtl8192ee/trx.o
+
+
+
+BT_COEXIST_OBJS:=	btcoexist/halbtc8192e2ant.o\
+			btcoexist/halbtc8723b1ant.o\
+			btcoexist/halbtc8723b2ant.o\
+			btcoexist/halbtc8821a1ant.o\
+			btcoexist/halbtc8821a2ant.o\
+			btcoexist/halbtcoutsrc.o\
+			btcoexist/rtl_btc.o
+
+r8192ee-objs += $(PCI_MAIN_OBJS) $(PCI_8192EE_HAL_OBJS) $(BT_COEXIST_OBJS)
+
+obj-$(CONFIG_R8192EE) += r8192ee.o
+
+ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/staging/rtl8192ee/TODO b/drivers/staging/rtl8192ee/TODO
new file mode 100644
index 0000000..162092a
--- /dev/null
+++ b/drivers/staging/rtl8192ee/TODO
@@ -0,0 +1,12 @@
+TODO:
+- convert any remaining unusual variable types
+- find codes that can use %pM and %Nph formatting
+- checkpatch.pl fixes - most of the remaining ones are lines too long. Many
+  of them will require refactoring
+- merge Realtek's bugfixes and new features into the driver
+- Convert the versions of rtlwifi and btcoexist in drivers/net/wireless/rtlwifi/...
+  to work with the RTL8192EE
+- move this driver to drivers/net/wireless/rtlwifi
+
+Please send any patches to Greg Kroah-Hartman <gregkh@linux.com>,
+and Larry Finger <Larry.Finger@lwfinger.net>.
-- 
1.8.4.5
