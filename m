From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 10/12] net-caif: add CAIF Kconfig and Makefiles
Date: Wed, 31 Mar 2010 01:56:28 +0200
Message-ID: <1269993390-23830-11-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-6-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-7-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-8-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-9-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-10-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756287Ab0C3X5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:57:17 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CCDD6VAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:55 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:55 +0200 (CEST)
In-reply-to: <1269993390-23830-10-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Kconfig and Makefiles with options for:
CAIF:        Including caif
CAIF_DEBUG:  CAIF Debug
CAIF_NETDEV: CAIF Network Device for GPRS Contexts

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/Kconfig       |    2 ++
 net/Makefile      |    1 +
 net/caif/Kconfig  |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/caif/Makefile |   26 ++++++++++++++++++++++++++
 4 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..9342f7b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -275,5 +275,7 @@ source "net/wimax/Kconfig"
 
 source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
+source "net/caif/Kconfig"
+
 
 endif   # if NET
diff --git a/net/Makefile b/net/Makefile
index 1542e72..a5eae27 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -56,6 +56,7 @@ obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
+obj-$(CONFIG_CAIF)		+= caif/
 ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
diff --git a/net/caif/Kconfig b/net/caif/Kconfig
new file mode 100644
index 0000000..cd1daf6
--- /dev/null
+++ b/net/caif/Kconfig
@@ -0,0 +1,48 @@
+#
+# CAIF net configurations
+#
+
+#menu "CAIF Support"
+comment "CAIF Support"
+menuconfig CAIF
+	tristate "Enable CAIF support"
+	select CRC_CCITT
+	default n
+	---help---
+	The "Communication CPU to Application CPU Interface" (CAIF) is a packet
+	based connection-oriented MUX protocol developed by ST-Ericsson for use
+	with its modems. It is accessed from user space as sockets (PF_CAIF).
+
+	Say Y (or M) here if you build for a phone product (e.g. Android or
+	MeeGo ) that uses CAIF as transport, if unsure say N.
+
+	If you select to build it as module then CAIF_NETDEV also needs to be
+	built as modules. You will also need to say yes to any CAIF physical
+	devices that your platform requires.
+
+	See Documentation/networking/caif for a further explanation on how to
+	use and configure CAIF.
+
+if CAIF
+
+config  CAIF_DEBUG
+	bool "Enable Debug"
+	default n
+	--- help ---
+	Enable the inclusion of debug code in the CAIF stack.
+	Be aware that doing this will impact performance.
+	If unsure say N.
+
+
+config CAIF_NETDEV
+	tristate "CAIF GPRS Network device"
+	default CAIF
+	---help---
+	Say Y if you will be using a CAIF based GPRS network device.
+	This can be either built-in or a loadable module,
+	If you select to build it as a built-in then the main CAIF device must
+	also be a built-in.
+	If unsure say Y.
+
+endif
+#endmenu
diff --git a/net/caif/Makefile b/net/caif/Makefile
new file mode 100644
index 0000000..34852af
--- /dev/null
+++ b/net/caif/Makefile
@@ -0,0 +1,26 @@
+ifeq ($(CONFIG_CAIF_DEBUG),1)
+CAIF_DBG_FLAGS := -DDEBUG
+endif
+
+ccflags-y := $(CAIF_FLAGS) $(CAIF_DBG_FLAGS)
+
+caif-objs := caif_dev.o \
+	cfcnfg.o cfmuxl.o cfctrl.o  \
+	cffrml.o cfveil.o cfdbgl.o\
+	cfserl.o cfdgml.o  \
+	cfrfml.o cfvidl.o cfutill.o \
+	cfsrvl.o cfpkt_skbuff.o caif_config_util.o
+clean-dirs:= .tmp_versions
+
+clean-files:= \
+	Module.symvers \
+	modules.order \
+	*.cmd \
+	*.o \
+	*~
+
+obj-$(CONFIG_CAIF) += caif.o
+obj-$(CONFIG_CAIF_NETDEV) += chnl_net.o
+obj-$(CONFIG_CAIF) += caif_socket.o
+
+export-objs := caif.o
-- 
1.6.3.3

