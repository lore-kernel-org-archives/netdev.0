From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 01/15] net: introduce legacy dir to absorb 10Mbit, ISA, EISA drivers
Date: Thu, 28 Oct 2010 21:19:05 -0400
Message-ID: <1288315159-1350-2-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33960 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449Ab0J2BT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:26 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are lots of drivers that date back to the early 1990's when
Linux was started, and they correspond to hardware and bus
technologies that have largely disappeared from in-use hardware over
10 years ago.

There is no need to have these drivers polluting the namespace
in the top level drivers directory any longer; relocation to a
subdirectory is long overdue.  Start by creating this new home
for these drivers so that they can be targeted and relocated.

By leaving the default to include the legacy/Kconfig, we ensure
people who have existing stores of their own .config files will
not have drivers silently dropped from their builds.

Since the legacy drivers have their probe ordering defined in
the Space.c file, we don't have to strictly maintain any link
order in moving things from Makefile to legacy/Makefile.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig         |   14 ++++++++++++++
 drivers/net/Makefile        |    1 +
 drivers/net/legacy/Kconfig  |    2 ++
 drivers/net/legacy/Makefile |    3 +++
 4 files changed, 20 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/legacy/Kconfig
 create mode 100644 drivers/net/legacy/Makefile

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f24179d..9515f76 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -28,6 +28,20 @@ menuconfig NETDEVICES
 # that for each of the symbols.
 if NETDEVICES
 
+config NETDEVICES_LEGACY
+	default y
+	bool "Legacy 10+ year old drivers (10Mbit, ISA, EISA, MCA etc.)"
+	---help---
+	  There are a lot of drivers that exist for really old network
+	  hardware that have long since been out of production, and
+	  are not really in active use by anyone with hardware that is
+	  less than ten years old. Unless you are trying to use really
+	  old hardware, you can say no here.
+
+if NETDEVICES_LEGACY
+source "drivers/net/legacy/Kconfig"
+endif
+
 config IFB
 	tristate "Intermediate Functional Block support"
 	depends on NET_CLS_ACT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b8bf93d..8045271 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -299,3 +299,4 @@ obj-$(CONFIG_CAIF) += caif/
 
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_PCH_GBE) += pch_gbe/
+obj-$(CONFIG_NETDEVICES_LEGACY) += legacy/
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
new file mode 100644
index 0000000..4c23adf
--- /dev/null
+++ b/drivers/net/legacy/Kconfig
@@ -0,0 +1,2 @@
+
+# Legacy drivers for ancient ISA/EISA bus devices and the like.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
new file mode 100644
index 0000000..33fd752
--- /dev/null
+++ b/drivers/net/legacy/Makefile
@@ -0,0 +1,3 @@
+#
+# Makefile for the Linux legacy network device drivers.
+#
-- 
1.7.3.2.146.g2d444

