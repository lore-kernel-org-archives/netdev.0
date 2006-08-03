From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH v4 7/7] AMSO1100 Makefiles and Kconfig changes.
Date: Thu, 03 Aug 2006 16:07:38 -0500
Message-ID: <20060803210738.16572.74032.stgit@dell3.ogc.int>
References: <20060803210723.16572.34829.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:52122 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S932099AbWHCVHi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:07:38 -0400
To: rdreier@cisco.com
In-Reply-To: <20060803210723.16572.34829.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



---

 drivers/infiniband/Kconfig             |    1 +
 drivers/infiniband/Makefile            |    1 +
 drivers/infiniband/hw/amso1100/Kbuild  |   10 ++++++++++
 drivers/infiniband/hw/amso1100/Kconfig |   15 +++++++++++++++
 drivers/infiniband/hw/amso1100/README  |   11 +++++++++++
 5 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 69a53d4..47f1de5 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -36,6 +36,7 @@ config INFINIBAND_ADDR_TRANS
 
 source "drivers/infiniband/hw/mthca/Kconfig"
 source "drivers/infiniband/hw/ipath/Kconfig"
+source "drivers/infiniband/hw/amso1100/Kconfig"
 
 source "drivers/infiniband/ulp/ipoib/Kconfig"
 
diff --git a/drivers/infiniband/Makefile b/drivers/infiniband/Makefile
index c7ff58c..ec330d5 100644
--- a/drivers/infiniband/Makefile
+++ b/drivers/infiniband/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_INFINIBAND)		+= core/
 obj-$(CONFIG_INFINIBAND_MTHCA)		+= hw/mthca/
 obj-$(CONFIG_IPATH_CORE)		+= hw/ipath/
+obj-$(CONFIG_INFINIBAND_AMSO1100)	+= hw/amso1100/
 obj-$(CONFIG_INFINIBAND_IPOIB)		+= ulp/ipoib/
 obj-$(CONFIG_INFINIBAND_SRP)		+= ulp/srp/
 obj-$(CONFIG_INFINIBAND_ISER)		+= ulp/iser/
diff --git a/drivers/infiniband/hw/amso1100/Kbuild b/drivers/infiniband/hw/amso1100/Kbuild
new file mode 100644
index 0000000..e1f10ab
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/Kbuild
@@ -0,0 +1,10 @@
+EXTRA_CFLAGS += -Idrivers/infiniband/include
+
+ifdef CONFIG_INFINIBAND_AMSO1100_DEBUG
+EXTRA_CFLAGS += -DDEBUG
+endif
+
+obj-$(CONFIG_INFINIBAND_AMSO1100) += iw_c2.o
+
+iw_c2-y := c2.o c2_provider.o c2_rnic.o c2_alloc.o c2_mq.o c2_ae.o c2_vq.o \
+	c2_intr.o c2_cq.o c2_qp.o c2_cm.o c2_mm.o c2_pd.o
diff --git a/drivers/infiniband/hw/amso1100/Kconfig b/drivers/infiniband/hw/amso1100/Kconfig
new file mode 100644
index 0000000..809cb14
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/Kconfig
@@ -0,0 +1,15 @@
+config INFINIBAND_AMSO1100
+	tristate "Ammasso 1100 HCA support"
+	depends on PCI && INET && INFINIBAND
+	---help---
+	  This is a low-level driver for the Ammasso 1100 host
+	  channel adapter (HCA).
+
+config INFINIBAND_AMSO1100_DEBUG
+	bool "Verbose debugging output"
+	depends on INFINIBAND_AMSO1100
+	default n
+	---help---
+	  This option causes the amso1100 driver to produce a bunch of
+	  debug messages.  Select this if you are developing the driver
+	  or trying to diagnose a problem.
diff --git a/drivers/infiniband/hw/amso1100/README b/drivers/infiniband/hw/amso1100/README
new file mode 100644
index 0000000..1331353
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/README
@@ -0,0 +1,11 @@
+This is the OpenFabrics provider driver for the 
+AMSO1100 1Gb RNIC adapter. 
+
+This adapter is available in limited quantities 
+for development purposes from Open Grid Computing.
+
+This driver requires the IWCM and CMA mods necessary
+to support iWARP.
+
+Contact tom@opengridcomputing.com for more information.
+
