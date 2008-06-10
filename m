From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [PATCH v4 12/14] QLogic VNIC: Driver Kconfig and Makefile.
Date: Tue, 10 Jun 2008 17:08:18 -0400
Message-ID: <20080610210818.11186.51465.stgit@dale>
References: <20080610205633.11186.45499.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.186.4.11] ([198.186.4.11]:19260 "EHLO
	dale.dev.silverstorm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754144AbYFJVEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 17:04:44 -0400
In-Reply-To: <20080610205633.11186.45499.stgit@dale>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

