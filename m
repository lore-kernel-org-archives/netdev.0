From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v6 10/12] net-caif: add CAIF Kconfig and Makefiles
Date: Mon,  1 Mar 2010 13:12:37 +0100
Message-ID: <1267445559-1911-11-git-send-email-sjur.brandeland@stericsson.com>
References: <1267445559-1911-1-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-2-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-3-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-4-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-5-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-6-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-7-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-8-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-9-git-send-email-sjur.brandeland@stericsson.com>
 <1267445559-1911-10-git-send-email-sjur.brandeland@stericsson.com>
Cc: daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gktv.no ([80.239.85.213]:33855 "EHLO mail.gktv.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359Ab0CAMNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 07:13:10 -0500
In-Reply-To: <1267445559-1911-10-git-send-email-sjur.brandeland@stericsson.com>
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
 net/caif/Makefile |   27 +++++++++++++++++++++++++++
 4 files changed, 78 insertions(+), 0 deletions(-)

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
index 0000000..65a926d
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
+	Say Y (or M) here if you build for a phone product (e.g. Android) that
+	uses CAIF as transport, if unsure say N.
+
+	If you select to build it as module then CAIF_SOCK and CAIF_NETDEV also
+	needs to be built as modules. You will also need to say yes to any CAIF
+	physical devices that your platform requires.
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
index 0000000..031a4e0
--- /dev/null
+++ b/net/caif/Makefile
@@ -0,0 +1,27 @@
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
+
-- 
1.6.3.3

