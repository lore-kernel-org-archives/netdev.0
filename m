From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] NET: Officially deprecate "ether=" and schedule for removal.
Date: Mon, 3 Sep 2007 07:30:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0709030725420.3962@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:58854 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbXICLmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 07:42:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Officially deprecate the boot-time "ether=" option in favour of
"netdev=", update the documentation accordingly in various places, and
schedule removal for September of 2008.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

  i realize that some people have strong feelings about removing
options because of backward compatibility, so i'm easy regarding this
submission.  i just had the patch lying around so i figured i'd send
it on and someone higher up the food chain can make the call one way
or the other.

  compile and boot-time tested on i386 with "make defconfig".


 Documentation/feature-removal-schedule.txt |    6 ++++++
 Documentation/kernel-parameters.txt        |    2 ++
 Documentation/m68k/kernel-options.txt      |    6 +++++-
 Documentation/networking/3c505.txt         |    3 ++-
 drivers/net/3c59x.c                        |    3 ++-
 drivers/net/atp.c                          |    2 +-
 drivers/net/es3210.c                       |    5 +++++
 net/ethernet/eth.c                         |   13 ++++++++++++-
 8 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index b9a3fdc..656a71a 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -298,3 +298,9 @@ Why:	All mthca hardware also supports MSI-X, which provides
 Who:	Roland Dreier <rolandd@cisco.com>

 ---------------------------
+
+What:	"ether=" boot-time option
+When:	September 2008
+Why:	Obsoleted by newer and equivalent "netdev=" option.
+Who:	Robert P. J. Day <rpjday@mindspring.com> or whoever else wants to
+	do it when the time comes.
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index b41cde3..47a9cf1 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -621,6 +621,8 @@ and is between 256 and 4096 characters. It is defined in the file
 	ether=		[HW,NET] Ethernet cards parameters
 			This option is obsoleted by the "netdev=" option, which
 			has equivalent usage. See its documentation for details.
+			"ether=" has been scheduled for removal -- see the file
+			Documentation/feature-removal-schedule.txt.

 	eurwdt=		[HW,WDT] Eurotech CPU-1220/1410 onboard watchdog.
 			Format: <io>[,<irq>]
diff --git a/Documentation/m68k/kernel-options.txt b/Documentation/m68k/kernel-options.txt
index 59108ce..3ec32d2 100644
--- a/Documentation/m68k/kernel-options.txt
+++ b/Documentation/m68k/kernel-options.txt
@@ -218,7 +218,7 @@ drive (with "root=").
 3) General Device Options (Amiga and Atari)
 ===========================================

-3.1) ether=
+3.1) ether=  [Equivalently, netdev=]
 -----------

 Syntax: ether=[<irq>[,<base_addr>[,<mem_start>[,<mem_end>]]]],<dev-name>
@@ -233,6 +233,10 @@ Linux/m68k (ariadne, a2065, hydra) don't use them because Zorro boards
 are really Plug-'n-Play, so the "ether=" option is useless altogether
 for Linux/m68k.

+  NOTE:  The "ether=" option is deprecated in favour of the newer
+"netdev=" option.  "ether=" has been scheduled for removal -- see the
+file Documentation/feature-removal-schedule.txt for details.
+

 3.2) hd=
 --------
diff --git a/Documentation/networking/3c505.txt b/Documentation/networking/3c505.txt
index b9d5b72..d79d31d 100644
--- a/Documentation/networking/3c505.txt
+++ b/Documentation/networking/3c505.txt
@@ -5,7 +5,8 @@ The default DMA channel is 6; this is _not_ autoprobed, so you must
 make sure you configure it correctly.  If loading the driver as a
 module, you can do this with "modprobe 3c505 dma=n".  If the driver is
 linked statically into the kernel, you must either use an "ether="
-statement on the command line, or change the definition of ELP_DMA in 3c505.h.
+(or equivalent and preferred "netdev=") statement on the command line,
+or change the definition of ELP_DMA in 3c505.h.

 The driver will warn you if it has to fall back on the compiled in
 default DMA channel.
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index a8c0f43..0ae3561 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1043,7 +1043,8 @@ static int __devinit vortex_probe1(struct device *gendev,
 	if (dev->mem_start) {
 		/*
 		 * The 'options' param is passed in as the third arg to the
-		 * LILO 'ether=' argument for non-modular use
+		 * LILO 'ether=' (or equivalent and preferred 'netdev=') argument
+		 * for non-modular use
 		 */
 		option = dev->mem_start;
 	}
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 82d78ff..d9cd8bb 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -114,7 +114,7 @@ static int xcvr[NUM_UNITS]; 			/* The data transfer mode. */

 	The data transfer mode is stored in the 'dev->if_port' field.  Its default
 	value is '4'.  It may be overridden at boot-time using the third parameter
-	to the "ether=..." initialization.
+	to the "ether=..." (or equivalent and preferred "netdev=...") initialization.

 	The header file <atp.h> provides inline functions that encapsulate the
 	register and data access methods.  These functions are hand-tuned to
diff --git a/drivers/net/es3210.c b/drivers/net/es3210.c
index 822e5bf..fdfbd59 100644
--- a/drivers/net/es3210.c
+++ b/drivers/net/es3210.c
@@ -40,6 +40,11 @@
 	   these registers is disabled there. In the meantime, boot with:
 	   ether=<IRQ>,0,0x<shared_mem_addr>,eth0 to override the IRQ and
 	   shared memory detection. (The i/o port detection is okay.)
+
+	   NOTE:  The "ether=" option has been deprecated in favour of the
+	   newer and equivalent "netdev=" option, and has been scheduled for
+	   removal.  See Documentation/feature-removal-schedule.txt for
+	   details.

 	2) Module support currently untested. Probably works though.

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 12c7657..45a3e9c 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -31,6 +31,8 @@
  *				  older network drivers and IFF_ALLMULTI.
  *	Christer Weinigel	: Better rebuild header message.
  *             Andrew Morton    : 26Feb01: kill ether_setup() - use netdev_boot_setup().
+ *             Robert P. J. Day : Add ether_boot_setup() to allow deprecation warning
+				  for "ether=" boot-time option.
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -60,7 +62,16 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>

-__setup("ether=", netdev_boot_setup);
+static int __init
+ether_boot_setup(char *str)
+{
+	printk(KERN_NOTICE "The 'ether' option is deprecated and "
+		"is scheduled for removal in late 2008\n");
+	printk(KERN_NOTICE "Use 'netdev=<value>' instead\n");
+	return netdev_boot_setup(str);
+}
+
+__setup("ether=", ether_boot_setup);

 /**
  * eth_header - create the Ethernet header




-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
