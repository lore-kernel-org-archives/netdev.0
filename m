From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 20/21] RDS: Kconfig and Makefile
Date: Mon, 26 Jan 2009 18:17:57 -0800
Message-ID: <1233022678-9259-21-git-send-email-andy.grover@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet14.oracle.com ([148.87.113.126]:23334 "EHLO
	rgminet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbZA0CTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 21:19:35 -0500
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rgminet14.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n0R2MFZh010639
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 02:22:17 GMT
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add RDS Kconfig and Makefile, and modify infiniband's to add
us to the build.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 drivers/infiniband/Kconfig          |    2 ++
 drivers/infiniband/Makefile         |    1 +
 drivers/infiniband/ulp/rds/Kconfig  |   13 +++++++++++++
 drivers/infiniband/ulp/rds/Makefile |   13 +++++++++++++
 4 files changed, 29 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/rds/Kconfig
 create mode 100644 drivers/infiniband/ulp/rds/Makefile

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index dd0db67..1cba524 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -54,4 +54,6 @@ source "drivers/infiniband/ulp/srp/Kconfig"
 
 source "drivers/infiniband/ulp/iser/Kconfig"
 
+source "drivers/infiniband/ulp/rds/Kconfig"
+
 endif # INFINIBAND
diff --git a/drivers/infiniband/Makefile b/drivers/infiniband/Makefile
index ed35e44..39d0203 100644
--- a/drivers/infiniband/Makefile
+++ b/drivers/infiniband/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_INFINIBAND_NES)		+= hw/nes/
 obj-$(CONFIG_INFINIBAND_IPOIB)		+= ulp/ipoib/
 obj-$(CONFIG_INFINIBAND_SRP)		+= ulp/srp/
 obj-$(CONFIG_INFINIBAND_ISER)		+= ulp/iser/
+obj-$(CONFIG_INFINIBAND_ISER)		+= ulp/rds/
diff --git a/drivers/infiniband/ulp/rds/Kconfig b/drivers/infiniband/ulp/rds/Kconfig
new file mode 100644
index 0000000..bbc2ba4
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/Kconfig
@@ -0,0 +1,13 @@
+
+config INFINIBAND_RDS
+	tristate "Reliable Datagram Sockets (RDS) (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	---help---
+	  RDS provides reliable, sequenced delivery of datagrams
+	  over Infiniband.
+
+config INFINIBAND_RDS_DEBUG
+        bool "Debugging messages"
+	depends on INFINIBAND_RDS
+        default n
+
diff --git a/drivers/infiniband/ulp/rds/Makefile b/drivers/infiniband/ulp/rds/Makefile
new file mode 100644
index 0000000..d470550
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/Makefile
@@ -0,0 +1,13 @@
+obj-$(CONFIG_INFINIBAND_RDS) += ib_rds.o
+
+ib_rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
+			recv.o send.o stats.o sysctl.o threads.o transport.o \
+			loop.o page.o rdma.o
+
+ib_rds-y += ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
+			ib_sysctl.o ib_rdma.o
+
+ifeq ($(CONFIG_INFINIBAND_RDS_DEBUG), y)
+EXTRA_CFLAGS += -DDEBUG
+endif
+
-- 
1.5.6.3

