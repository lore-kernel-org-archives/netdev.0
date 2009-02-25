From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 22/26] RDS: Kconfig and Makefile
Date: Tue, 24 Feb 2009 17:30:39 -0800
Message-ID: <1235525443-9007-23-git-send-email-andy.grover@oracle.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49069 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbZBYBbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:31:39 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add RDS Kconfig and Makefile, and modify net/'s to add
us to the build.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/Kconfig      |    1 +
 net/Makefile     |    1 +
 net/rds/Kconfig  |   13 +++++++++++++
 net/rds/Makefile |   14 ++++++++++++++
 4 files changed, 29 insertions(+), 0 deletions(-)
 create mode 100644 net/rds/Kconfig
 create mode 100644 net/rds/Makefile

diff --git a/net/Kconfig b/net/Kconfig
index a12bae0..6b39ede 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -171,6 +171,7 @@ endif
 
 source "net/dccp/Kconfig"
 source "net/sctp/Kconfig"
+source "net/rds/Kconfig"
 source "net/tipc/Kconfig"
 source "net/atm/Kconfig"
 source "net/802/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index 0fcce89..9e00a55 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -49,6 +49,7 @@ obj-y				+= 8021q/
 endif
 obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
+obj-$(CONFIG_RDS)		+= rds/
 obj-y				+= wireless/
 obj-$(CONFIG_MAC80211)		+= mac80211/
 obj-$(CONFIG_TIPC)		+= tipc/
diff --git a/net/rds/Kconfig b/net/rds/Kconfig
new file mode 100644
index 0000000..63bd370
--- /dev/null
+++ b/net/rds/Kconfig
@@ -0,0 +1,13 @@
+
+config RDS
+	tristate "Reliable Datagram Sockets (RDS) (EXPERIMENTAL)"
+	depends on INET && INFINIBAND_IPOIB && EXPERIMENTAL
+	---help---
+	  RDS provides reliable, sequenced delivery of datagrams
+	  over Infiniband.
+
+config RDS_DEBUG
+        bool "Debugging messages"
+	depends on RDS
+        default n
+
diff --git a/net/rds/Makefile b/net/rds/Makefile
new file mode 100644
index 0000000..51f2758
--- /dev/null
+++ b/net/rds/Makefile
@@ -0,0 +1,14 @@
+obj-$(CONFIG_RDS) += rds.o
+rds-y :=	af_rds.o bind.o cong.o connection.o info.o message.o   \
+			recv.o send.o stats.o sysctl.o threads.o transport.o \
+			loop.o page.o rdma.o \
+			rdma_transport.o \
+			ib.o ib_cm.o ib_recv.o ib_ring.o ib_send.o ib_stats.o \
+			ib_sysctl.o ib_rdma.o \
+			iw.o iw_cm.o iw_recv.o iw_ring.o iw_send.o iw_stats.o \
+			iw_sysctl.o iw_rdma.o
+
+ifeq ($(CONFIG_RDS_DEBUG), y)
+EXTRA_CFLAGS += -DDEBUG
+endif
+
-- 
1.5.6.3

