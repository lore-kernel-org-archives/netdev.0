From: "Steve Wise" <swise@opengridcomputing.com>
Subject: [PATCH v3 7/7] AMSO1100 Makefiles and Kconfig
 changes.
Date: Tue, 20 Jun 2006 15:31:26 -0500
Message-ID: <20060620203126.31536.78501.stgit@stevo-desktop>
References: <20060620203050.31536.5341.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com,
	mshefty@ichips.intel.com
In-Reply-To: <20060620203050.31536.5341.stgit@stevo-desktop>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


Review Changes:

- C2DEBUG -> DEBUG
---

 drivers/infiniband/Kconfig             |    1 +
 drivers/infiniband/Makefile            |    1 +
 drivers/infiniband/hw/amso1100/Kbuild  |   10 ++++++++++
 drivers/infiniband/hw/amso1100/Kconfig |   15 +++++++++++++++
 drivers/infiniband/hw/amso1100/README  |   11 +++++++++++
 5 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index ba2d650..04e6d4f 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -36,6 +36,7 @@ config INFINIBAND_ADDR_TRANS
 
 source "drivers/infiniband/hw/mthca/Kconfig"
 source "drivers/infiniband/hw/ipath/Kconfig"
+source "drivers/infiniband/hw/amso1100/Kconfig"
 
 source "drivers/infiniband/ulp/ipoib/Kconfig"
 
diff --git a/drivers/infiniband/Makefile b/drivers/infiniband/Makefile
index eea2732..e2b93f9 100644
--- a/drivers/infiniband/Makefile
+++ b/drivers/infiniband/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_INFINIBAND)		+= core/
 obj-$(CONFIG_INFINIBAND_MTHCA)		+= hw/mthca/
 obj-$(CONFIG_IPATH_CORE)		+= hw/ipath/
+obj-$(CONFIG_INFINIBAND_AMSO1100)	+= hw/amso1100/
 obj-$(CONFIG_INFINIBAND_IPOIB)		+= ulp/ipoib/
 obj-$(CONFIG_INFINIBAND_SRP)		+= ulp/srp/
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
