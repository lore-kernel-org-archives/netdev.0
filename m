From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH v2] et131x: Promote staging et131x driver to drivers/net
Date: Tue, 23 Sep 2014 21:05:23 +0100
Message-ID: <1411502723-4628-1-git-send-email-mark.einon@gmail.com>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, angus@agibson.me, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, joe@perches.com,
 Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org,
	davem@davemloft.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

This patch moves the et131x gigabit ethernet driver from drivers/staging
to drivers/net/ethernet/agere.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---

Changes from v1:

-modified MAINTAINERS in scope with changes
-Fixed typo in Kconfig, Atheros -> Agere
-Made review changes from Tobias Klauser, see patchset
   http://marc.info/?l=linux-driver-devel&m=141150128909523&w=2
-v2 patch formatted with '-M' git-format-patch flag

** Patch applies and tested on linux-next tag next-20140923, on top of the 8
patches at http://marc.info/?l=linux-driver-devel&m=141141591110262&w=2 and the
four patches linked above. Posting in such a messy way in order to hopefully
solicit enough feedback before the upcoming merge window **

 MAINTAINERS                                        | 10 +++----
 drivers/net/ethernet/Kconfig                       |  1 +
 drivers/net/ethernet/Makefile                      |  1 +
 drivers/net/ethernet/agere/Kconfig                 | 31 ++++++++++++++++++++++
 .../et131x => net/ethernet/agere}/Makefile         |  0
 .../et131x => net/ethernet/agere}/et131x.c         |  0
 .../et131x => net/ethernet/agere}/et131x.h         |  0
 drivers/staging/Kconfig                            |  2 --
 drivers/staging/Makefile                           |  1 -
 drivers/staging/et131x/Kconfig                     | 10 -------
 drivers/staging/et131x/README                      | 15 -----------
 11 files changed, 38 insertions(+), 33 deletions(-)
 create mode 100644 drivers/net/ethernet/agere/Kconfig
 rename drivers/{staging/et131x => net/ethernet/agere}/Makefile (100%)
 rename drivers/{staging/et131x => net/ethernet/agere}/et131x.c (100%)
 rename drivers/{staging/et131x => net/ethernet/agere}/et131x.h (100%)
 delete mode 100644 drivers/staging/et131x/Kconfig
 delete mode 100644 drivers/staging/et131x/README

diff --git a/MAINTAINERS b/MAINTAINERS
index 637112c..26b5238 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3572,6 +3572,11 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kristoffer/linux-hpc.git
 F:	drivers/video/fbdev/s1d13xxxfb.c
 F:	include/video/s1d13xxxfb.h
 
+ET131X NETWORK DRIVER
+M:	Mark Einon <mark.einon@gmail.com>
+S:	Odd Fixes
+F:	drivers/net/ethernet/agere/
+
 ETHERNET BRIDGE
 M:	Stephen Hemminger <stephen@networkplumber.org>
 L:	bridge@lists.linux-foundation.org
@@ -8764,11 +8769,6 @@ M:	H Hartley Sweeten <hsweeten@visionengravers.com>
 S:	Odd Fixes
 F:	drivers/staging/comedi/
 
-STAGING - ET131X NETWORK DRIVER
-M:	Mark Einon <mark.einon@gmail.com>
-S:	Odd Fixes
-F:	drivers/staging/et131x/
-
 STAGING - FLARION FT1000 DRIVERS
 M:	Marek Belisko <marek.belisko@gmail.com>
 S:	Odd Fixes
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index dc7406c..d48fc9c 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -20,6 +20,7 @@ config SUNGEM_PHY
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
+source "drivers/net/ethernet/agere/Kconfig"
 source "drivers/net/ethernet/allwinner/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/altera/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 224a018..89207ac 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
 obj-$(CONFIG_GRETH) += aeroflex/
+obj-$(CONFIG_NET_VENDOR_AGERE) += agere/
 obj-$(CONFIG_NET_VENDOR_ALLWINNER) += allwinner/
 obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_ALTERA_TSE) += altera/
diff --git a/drivers/net/ethernet/agere/Kconfig b/drivers/net/ethernet/agere/Kconfig
new file mode 100644
index 0000000..63e805d
--- /dev/null
+++ b/drivers/net/ethernet/agere/Kconfig
@@ -0,0 +1,31 @@
+#
+# Agere device configuration
+#
+
+config NET_VENDOR_AGERE
+	bool "Agere devices"
+	default y
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Agere devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+if NET_VENDOR_AGERE
+
+config ET131X
+	tristate "Agere ET-1310 Gigabit Ethernet support"
+	depends on PCI
+	select PHYLIB
+	---help---
+	  This driver supports Agere ET-1310 ethernet adapters.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called et131x.
+
+endif # NET_VENDOR_AGERE
diff --git a/drivers/staging/et131x/Makefile b/drivers/net/ethernet/agere/Makefile
similarity index 100%
rename from drivers/staging/et131x/Makefile
rename to drivers/net/ethernet/agere/Makefile
diff --git a/drivers/staging/et131x/et131x.c b/drivers/net/ethernet/agere/et131x.c
similarity index 100%
rename from drivers/staging/et131x/et131x.c
rename to drivers/net/ethernet/agere/et131x.c
diff --git a/drivers/staging/et131x/et131x.h b/drivers/net/ethernet/agere/et131x.h
similarity index 100%
rename from drivers/staging/et131x/et131x.h
rename to drivers/net/ethernet/agere/et131x.h
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 6e2d6fd..9d18a1c 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -24,8 +24,6 @@ menuconfig STAGING
 
 if STAGING
 
-source "drivers/staging/et131x/Kconfig"
-
 source "drivers/staging/slicoss/Kconfig"
 
 source "drivers/staging/wlan-ng/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 74c679e..8c56326 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -4,7 +4,6 @@
 obj-$(CONFIG_STAGING)		+= staging.o
 
 obj-y				+= media/
-obj-$(CONFIG_ET131X)		+= et131x/
 obj-$(CONFIG_SLICOSS)		+= slicoss/
 obj-$(CONFIG_PRISM2_USB)	+= wlan-ng/
 obj-$(CONFIG_COMEDI)		+= comedi/
diff --git a/drivers/staging/et131x/Kconfig b/drivers/staging/et131x/Kconfig
deleted file mode 100644
index 8190f2a..0000000
--- a/drivers/staging/et131x/Kconfig
+++ /dev/null
@@ -1,10 +0,0 @@
-config ET131X
-	tristate "Agere ET-1310 Gigabit Ethernet support"
-	depends on PCI && NET && NETDEVICES
-	select PHYLIB
-	default n
-	---help---
-	  This driver supports Agere ET-1310 ethernet adapters.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called et131x.
diff --git a/drivers/staging/et131x/README b/drivers/staging/et131x/README
deleted file mode 100644
index 13c8168..0000000
--- a/drivers/staging/et131x/README
+++ /dev/null
@@ -1,15 +0,0 @@
-This is a driver for the ET1310 network device.
-
-Based on the driver found at https://sourceforge.net/projects/et131x/
-
-Cleaned up immensely by Olaf Hartman and Christoph Hellwig <hch@infradead.org>
-
-Note, the powermanagement options were removed from the vendor provided
-driver as they did not build properly at the time.
-
-TODO:
-
-Please send patches to:
-	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
-	Mark Einon <mark.einon@gmail.com>
-
-- 
2.1.0
