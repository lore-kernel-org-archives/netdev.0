From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 11/13] net-caif: add CAIF Kconfig and Makefiles
Date: Wed, 20 Jan 2010 23:55:28 +0100
Message-ID: <1264028130-14364-12-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490Ab0ATX4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:42 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00CFIIDPGCC0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:13 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:13 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Kconfig and Makefiles with options for:
CAIF:        Including caif
CAIF_DEBUG:  CAIF Debug
CAIF_SOCK:   CAIF Socket Implementation
CAIF_NETDEV: CAIF Network Device for GPRS Contexts

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/Kconfig       |    2 +
 net/Makefile      |    1 +
 net/caif/Kconfig  |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/caif/Makefile |   29 +++++++++++++++++++++++++++
 4 files changed, 89 insertions(+), 0 deletions(-)

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
index 0000000..7d32059
--- /dev/null
+++ b/net/caif/Kconfig
@@ -0,0 +1,57 @@
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
+	with its modems.
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
+config CAIF_SOCK
+	tristate "CAIF Sockets"
+	default CAIF
+	---help---
+	Say Y if you will be using CAIF Sockets.
+	This can be either built-in or a loadable module,
+	If you select to build it as a built-in then the main CAIF device must
+	also be a built-in,
+	If unsure say Y.
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
index 0000000..c49438b
--- /dev/null
+++ b/net/caif/Makefile
@@ -0,0 +1,29 @@
+ifeq ($(CONFIG_CAIF_DEBUG),1)
+CAIF_DBG_FLAGS := -DDEBUG
+endif
+
+ccflags-y := $(CAIF_FLAGS) $(CAIF_DBG_FLAGS)
+
+caif-objs := caif_dev.o caif_chnlif.o \
+	generic/cfcnfg.o generic/cfmuxl.o generic/cfctrl.o  \
+	generic/cffrml.o generic/cfveil.o generic/cflist.o  \
+	generic/cfserl.o generic/cfdgml.o  \
+	generic/cfrfml.o generic/cfvidl.o generic/cfutill.o \
+	generic/cfsrvl.o generic/cfpkt_skbuff.o caif_config_util.o
+
+clean-dirs:= .tmp_versions
+
+clean-files:= \
+	Module.symvers \
+	modules.order \
+	*.cmd \
+	*~ \
+	generic/*.o \
+	generic/*~
+
+obj-$(CONFIG_CAIF) += caif.o
+obj-$(CONFIG_CAIF_NETDEV) += chnl_net.o
+obj-$(CONFIG_CAIF_SOCK) += caif_socket.o
+
+export-objs := caif.o
+
-- 
1.6.3.3

