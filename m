From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] net/ethernet: sc92031 is not Realtek
Date: Tue, 25 Oct 2011 20:32:24 -0200
Message-ID: <1319581944-2707-1-git-send-email-cesarb@cesarb.net>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Donald Becker <becker@scyld.com>,
	Cesar Eduardo Barros <cesarb@cesarb.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 25 Oct 2011 22:32:34 -0000
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While the SC92031 could be found on fake "Realtek" NICs, it has no
relationship to Realtek, and is actually from Silan.

Create a new subdirectory for silan and move sc92031 there.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/ethernet/Kconfig                      |    1 +
 drivers/net/ethernet/Makefile                     |    1 +
 drivers/net/ethernet/realtek/Kconfig              |   12 -------
 drivers/net/ethernet/realtek/Makefile             |    1 -
 drivers/net/ethernet/silan/Kconfig                |   33 +++++++++++++++++++++
 drivers/net/ethernet/silan/Makefile               |    5 +++
 drivers/net/ethernet/{realtek => silan}/sc92031.c |    0
 7 files changed, 40 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/silan/Kconfig
 create mode 100644 drivers/net/ethernet/silan/Makefile
 rename drivers/net/ethernet/{realtek => silan}/sc92031.c (100%)

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6dff5a0..597f4d4 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -159,6 +159,7 @@ config S6GMAC
 	  will be called s6gmac.
 
 source "drivers/net/ethernet/seeq/Kconfig"
+source "drivers/net/ethernet/silan/Kconfig"
 source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c53ad3a..be5dde0 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -58,6 +58,7 @@ obj-$(CONFIG_SH_ETH) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
+obj-$(CONFIG_NET_VENDOR_SILAN) += silan/
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index 84083ec..0578859 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -115,16 +115,4 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
-config SC92031
-	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
-	select CRC32
-	---help---
-	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the Silan SC92031 chip (sometimes also called Rsltek 8139D). If you
-	  have one of these, say Y here.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sc92031.  This is recommended.
-
 endif # NET_VENDOR_REALTEK
diff --git a/drivers/net/ethernet/realtek/Makefile b/drivers/net/ethernet/realtek/Makefile
index e48cfb6..71b1da3 100644
--- a/drivers/net/ethernet/realtek/Makefile
+++ b/drivers/net/ethernet/realtek/Makefile
@@ -6,4 +6,3 @@ obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_R8169) += r8169.o
-obj-$(CONFIG_SC92031) += sc92031.o
diff --git a/drivers/net/ethernet/silan/Kconfig b/drivers/net/ethernet/silan/Kconfig
new file mode 100644
index 0000000..ae1ce17
--- /dev/null
+++ b/drivers/net/ethernet/silan/Kconfig
@@ -0,0 +1,33 @@
+#
+# Silan device configuration
+#
+
+config NET_VENDOR_SILAN
+	bool "Silan devices"
+	default y
+	depends on PCI && EXPERIMENTAL
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Silan devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_SILAN
+
+config SC92031
+	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
+	depends on PCI && EXPERIMENTAL
+	select CRC32
+	---help---
+	  This is a driver for the Fast Ethernet PCI network cards based on
+	  the Silan SC92031 chip (sometimes also called Rsltek 8139D). If you
+	  have one of these, say Y here.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sc92031.  This is recommended.
+
+endif # NET_VENDOR_SILAN
diff --git a/drivers/net/ethernet/silan/Makefile b/drivers/net/ethernet/silan/Makefile
new file mode 100644
index 0000000..4ad3523
--- /dev/null
+++ b/drivers/net/ethernet/silan/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Silan network device drivers.
+#
+
+obj-$(CONFIG_SC92031) += sc92031.o
diff --git a/drivers/net/ethernet/realtek/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
similarity index 100%
rename from drivers/net/ethernet/realtek/sc92031.c
rename to drivers/net/ethernet/silan/sc92031.c
-- 
1.7.6.4
