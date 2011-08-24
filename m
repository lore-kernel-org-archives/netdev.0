From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] plip: Move the PLIP driver
Date: Wed, 24 Aug 2011 02:02:45 -0700
Message-ID: <1314176570-20298-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Niibe Yutaka <gniibe@mri.co.jp>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28495 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756457Ab1HXJC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 05:02:56 -0400
In-Reply-To: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Parallel Line Internet Protocol (PLIP) driver into
drivers/net/plip/ and make the necessary Kconfig and Makefile changes.

CC: Niibe Yutaka <gniibe@mri.co.jp>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Alan Cox <alan@linux.intel.com>
---
 drivers/net/Kconfig           |   37 ++-----------------------------------
 drivers/net/Makefile          |    2 +-
 drivers/net/plip/Kconfig      |   38 ++++++++++++++++++++++++++++++++++++++
 drivers/net/plip/Makefile     |    5 +++++
 drivers/net/{ => plip}/plip.c |    0
 5 files changed, 46 insertions(+), 36 deletions(-)
 create mode 100644 drivers/net/plip/Kconfig
 create mode 100644 drivers/net/plip/Makefile
 rename drivers/net/{ => plip}/plip.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1d8fa95..3f72686 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -197,6 +197,8 @@ source "drivers/net/ethernet/Kconfig"
 
 source "drivers/net/fddi/Kconfig"
 
+source "drivers/net/plip/Kconfig"
+
 source "drivers/net/tokenring/Kconfig"
 
 source "drivers/net/wireless/Kconfig"
@@ -272,41 +274,6 @@ config RIONET_RX_SIZE
 	depends on RIONET
 	default "128"
 
-config PLIP
-	tristate "PLIP (parallel port) support"
-	depends on PARPORT
-	---help---
-	  PLIP (Parallel Line Internet Protocol) is used to create a
-	  reasonably fast mini network consisting of two (or, rarely, more)
-	  local machines.  A PLIP link from a Linux box is a popular means to
-	  install a Linux distribution on a machine which doesn't have a
-	  CD-ROM drive (a minimal system has to be transferred with floppies
-	  first). The kernels on both machines need to have this PLIP option
-	  enabled for this to work.
-
-	  The PLIP driver has two modes, mode 0 and mode 1.  The parallel
-	  ports (the connectors at the computers with 25 holes) are connected
-	  with "null printer" or "Turbo Laplink" cables which can transmit 4
-	  bits at a time (mode 0) or with special PLIP cables, to be used on
-	  bidirectional parallel ports only, which can transmit 8 bits at a
-	  time (mode 1); you can find the wiring of these cables in
-	  <file:Documentation/networking/PLIP.txt>.  The cables can be up to
-	  15m long.  Mode 0 works also if one of the machines runs DOS/Windows
-	  and has some PLIP software installed, e.g. the Crynwr PLIP packet
-	  driver (<http://oak.oakland.edu/simtel.net/msdos/pktdrvr-pre.html>)
-	  and winsock or NCSA's telnet.
-
-	  If you want to use PLIP, say Y and read the PLIP mini-HOWTO as well
-	  as the NET-3-HOWTO, both available from
-	  <http://www.tldp.org/docs.html#howto>.  Note that the PLIP
-	  protocol has been changed and this PLIP driver won't work together
-	  with the PLIP support in Linux versions 1.0.x.  This option enlarges
-	  your kernel by about 8 KB.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called plip. If unsure, say Y or M, in case you buy
-	  a laptop later.
-
 config SLIP
 	tristate "SLIP (serial line) support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index aff07bd..7013815 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -12,7 +12,6 @@ obj-$(CONFIG_VMXNET3) += vmxnet3/
 #
 # link order important here
 #
-obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_RIONET) += rionet.o
 
 #
@@ -39,6 +38,7 @@ obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_HIPPI) += hippi/
+obj-$(CONFIG_PLIP) += plip/
 onj-$(CONFIG_PPP) += ppp/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
diff --git a/drivers/net/plip/Kconfig b/drivers/net/plip/Kconfig
new file mode 100644
index 0000000..80c4a33
--- /dev/null
+++ b/drivers/net/plip/Kconfig
@@ -0,0 +1,38 @@
+#
+# Parallel Line Internet Protocol (PLIP) network device configuration
+#
+
+config PLIP
+	tristate "PLIP (parallel port) support"
+	depends on PARPORT
+	---help---
+	  PLIP (Parallel Line Internet Protocol) is used to create a
+	  reasonably fast mini network consisting of two (or, rarely, more)
+	  local machines.  A PLIP link from a Linux box is a popular means to
+	  install a Linux distribution on a machine which doesn't have a
+	  CD-ROM drive (a minimal system has to be transferred with floppies
+	  first). The kernels on both machines need to have this PLIP option
+	  enabled for this to work.
+
+	  The PLIP driver has two modes, mode 0 and mode 1.  The parallel
+	  ports (the connectors at the computers with 25 holes) are connected
+	  with "null printer" or "Turbo Laplink" cables which can transmit 4
+	  bits at a time (mode 0) or with special PLIP cables, to be used on
+	  bidirectional parallel ports only, which can transmit 8 bits at a
+	  time (mode 1); you can find the wiring of these cables in
+	  <file:Documentation/networking/PLIP.txt>.  The cables can be up to
+	  15m long.  Mode 0 works also if one of the machines runs DOS/Windows
+	  and has some PLIP software installed, e.g. the Crynwr PLIP packet
+	  driver (<http://oak.oakland.edu/simtel.net/msdos/pktdrvr-pre.html>)
+	  and winsock or NCSA's telnet.
+
+	  If you want to use PLIP, say Y and read the PLIP mini-HOWTO as well
+	  as the NET-3-HOWTO, both available from
+	  <http://www.tldp.org/docs.html#howto>.  Note that the PLIP
+	  protocol has been changed and this PLIP driver won't work together
+	  with the PLIP support in Linux versions 1.0.x.  This option enlarges
+	  your kernel by about 8 KB.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called plip. If unsure, say Y or M, in case you buy
+	  a laptop later.
diff --git a/drivers/net/plip/Makefile b/drivers/net/plip/Makefile
new file mode 100644
index 0000000..ed95879
--- /dev/null
+++ b/drivers/net/plip/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the PLIP network device drivers.
+#
+
+obj-$(CONFIG_PLIP) += plip.o
diff --git a/drivers/net/plip.c b/drivers/net/plip/plip.c
similarity index 100%
rename from drivers/net/plip.c
rename to drivers/net/plip/plip.c
-- 
1.7.6
