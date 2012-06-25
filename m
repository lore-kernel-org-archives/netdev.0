From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 7/8] LLDP: Kconfig and Makefile
Date: Mon, 25 Jun 2012 20:28:19 +0200
Message-ID: <1340648900-6547-8-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:56156 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab2FYS3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:29:04 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so3093894ggl.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:29:04 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds Kconfig and Makefile for LLDP, and sources these in
net/Makefile and net/Kconfig.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/Kconfig       |    1 +
 net/Makefile      |    1 +
 net/lldp/Kconfig  |   21 +++++++++++++++++++++
 net/lldp/Makefile |    7 +++++++
 4 files changed, 30 insertions(+)
 create mode 100644 net/lldp/Kconfig
 create mode 100644 net/lldp/Makefile

diff --git a/net/Kconfig b/net/Kconfig
index 245831b..cb724f2 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -216,6 +216,7 @@ source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
 source "net/openvswitch/Kconfig"
+source "net/lldp/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index 4f4ee08..39fbb8b 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -70,3 +70,4 @@ obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
+obj-$(CONFIG_LLDP)		+= lldp/
diff --git a/net/lldp/Kconfig b/net/lldp/Kconfig
new file mode 100644
index 0000000..0c59fbf
--- /dev/null
+++ b/net/lldp/Kconfig
@@ -0,0 +1,21 @@
+#
+# Link Layer Discovery Protocol (LLDP)
+# IEEE Std 802.1ab
+#
+
+config LLDP
+	tristate "Link Layer Discovery Protocol (LLDP) Support"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	  Enables experimental support for the LLDP protocol described in
+	  IEEE Std 802.1ab.
+
+	  The LLDP protocol allows nodes to advertise their identification,
+	  configuration and capabilities to neighbors on the same link.
+	  Currently, only advertisement is implemented.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called lldp.
+
+	  If unsure say N.
diff --git a/net/lldp/Makefile b/net/lldp/Makefile
new file mode 100644
index 0000000..e3c609f
--- /dev/null
+++ b/net/lldp/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Linux Link Layer Discovery Protocol (LLDP) implementation.
+#
+
+obj-$(CONFIG_LLDP) += lldp.o
+
+lldp-objs :=	lldp_core.o lldp_output.o lldpdu.o sysctl_net_lldp.o
-- 
1.7.10
