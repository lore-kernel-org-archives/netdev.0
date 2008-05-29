From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v3 12/13] QLogic VNIC: Driver Kconfig and
	Makefile.
Date: Thu, 29 May 2008 15:29:55 +0530
Message-ID: <20080529095955.9943.48616.stgit@localhost.localdomain>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080529095126.9943.84692.stgit@localhost.localdomain>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>

Kconfig and Makefile for the QLogic VNIC driver.

Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
---

 drivers/infiniband/ulp/qlgc_vnic/Kconfig  |   19 +++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/Makefile |   13 +++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/Kconfig
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/Makefile

diff --git a/drivers/infiniband/ulp/qlgc_vnic/Kconfig b/drivers/infiniband/ulp/qlgc_vnic/Kconfig
new file mode 100644
index 0000000..7b4030e
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/Kconfig
@@ -0,0 +1,19 @@
+config INFINIBAND_QLGC_VNIC
+	tristate "QLogic VNIC - Support for QLogic Ethernet Virtual I/O Controller"
+	depends on INFINIBAND && NETDEVICES && INET
+	---help---
+	  Support for the QLogic Ethernet Virtual I/O Controller
+	  (EVIC). In conjunction with the EVIC, this provides virtual
+	  ethernet interfaces and transports ethernet packets over
+	  InfiniBand so that you can communicate with Ethernet networks
+	  using your IB device.
+
+config INFINIBAND_QLGC_VNIC_STATS
+	bool "QLogic VNIC Statistics"
+	depends on INFINIBAND_QLGC_VNIC
+	default n
+	---help---
+	  This option compiles statistics collecting code into the
+	  data path of the QLogic VNIC driver to help in profiling and fine
+	  tuning. This adds some overhead in the interest of gathering
+	  data.
diff --git a/drivers/infiniband/ulp/qlgc_vnic/Makefile b/drivers/infiniband/ulp/qlgc_vnic/Makefile
new file mode 100644
index 0000000..509dd67
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/Makefile
@@ -0,0 +1,13 @@
+obj-$(CONFIG_INFINIBAND_QLGC_VNIC)		+= qlgc_vnic.o
+
+qlgc_vnic-y					:= vnic_main.o \
+						   vnic_ib.o \
+						   vnic_viport.o \
+						   vnic_control.o \
+						   vnic_data.o \
+						   vnic_netpath.o \
+						   vnic_config.o \
+						   vnic_sys.o \
+						   vnic_multicast.o
+
+qlgc_vnic-$(CONFIG_INFINIBAND_QLGC_VNIC_STATS)	+= vnic_stats.o
