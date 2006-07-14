From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [SLHC 1/4] Cleanup SLHC configuration
Date: Fri, 14 Jul 2006 12:15:40 +0100
Message-ID: <20060714111540.GB15058@linux-mips.org>
References: <20060713110615.GA19816@linux-mips.org> <20060713.220718.10298012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kkeil@suse.de, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:18823 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1751526AbWGNLPk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 07:15:40 -0400
Received: from localhost.localdomain ([127.0.0.1]:59608 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133779AbWGNLPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 12:15:39 +0100
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060713.220718.10298012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert selection of serial line header compression to use CONFIG_SLHC
rather than makefile ifeq uglyness.  This makes it easier to select
the SLHC module from other code.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 drivers/isdn/i4l/Kconfig |    1 +
 drivers/net/Kconfig      |    8 ++++++++
 drivers/net/Makefile     |   10 ++--------
 3 files changed, 11 insertions(+), 8 deletions(-)

Index: linux-net/drivers/isdn/i4l/Kconfig
===================================================================
--- linux-net.orig/drivers/isdn/i4l/Kconfig	2006-07-09 02:47:58.000000000 +0100
+++ linux-net/drivers/isdn/i4l/Kconfig	2006-07-10 01:35:45.000000000 +0100
@@ -5,6 +5,7 @@
 config ISDN_PPP
 	bool "Support synchronous PPP"
 	depends on INET
+	select SLHC
 	help
 	  Over digital connections such as ISDN, there is no need to
 	  synchronize sender and recipient's clocks with start and stop bits
Index: linux-net/drivers/net/Kconfig
===================================================================
--- linux-net.orig/drivers/net/Kconfig	2006-07-09 02:47:58.000000000 +0100
+++ linux-net/drivers/net/Kconfig	2006-07-10 01:35:45.000000000 +0100
@@ -2509,6 +2509,7 @@ config PLIP
 
 config PPP
 	tristate "PPP (point-to-point protocol) support"
+	select SLHC
 	---help---
 	  PPP (Point to Point Protocol) is a newer and better SLIP.  It serves
 	  the same purpose: sending Internet traffic over telephone (and other
@@ -2689,6 +2690,7 @@ config SLIP
 config SLIP_COMPRESSED
 	bool "CSLIP compressed headers"
 	depends on SLIP
+	select SLHC
 	---help---
 	  This protocol is faster than SLIP because it uses compression on the
 	  TCP/IP headers (not on the data itself), but it has to be supported
@@ -2701,6 +2703,12 @@ config SLIP_COMPRESSED
 	  <http://www.tldp.org/docs.html#howto>, explains how to configure
 	  CSLIP. This won't enlarge your kernel.
 
+config SLHC
+	tristate
+	help
+	  This option enables Van Jacobsen serial line header compression
+	  routines.
+
 config SLIP_SMART
 	bool "Keepalive and linefill"
 	depends on SLIP
Index: linux-net/drivers/net/Makefile
===================================================================
--- linux-net.orig/drivers/net/Makefile	2006-07-09 02:47:58.000000000 +0100
+++ linux-net/drivers/net/Makefile	2006-07-10 01:35:45.000000000 +0100
@@ -2,10 +2,6 @@
 # Makefile for the Linux network (ethercard) device drivers.
 #
 
-ifeq ($(CONFIG_ISDN_PPP),y)
-  obj-$(CONFIG_ISDN) += slhc.o
-endif
-
 obj-$(CONFIG_E1000) += e1000/
 obj-$(CONFIG_IBM_EMAC) += ibm_emac/
 obj-$(CONFIG_IXGB) += ixgb/
@@ -111,7 +107,7 @@ obj-$(CONFIG_NE_H8300) += ne-h8300.o 839
 
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 
-obj-$(CONFIG_PPP) += ppp_generic.o slhc.o
+obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
 obj-$(CONFIG_PPP_SYNC_TTY) += ppp_synctty.o
 obj-$(CONFIG_PPP_DEFLATE) += ppp_deflate.o
@@ -120,9 +116,7 @@ obj-$(CONFIG_PPP_MPPE) += ppp_mppe.o
 obj-$(CONFIG_PPPOE) += pppox.o pppoe.o
 
 obj-$(CONFIG_SLIP) += slip.o
-ifeq ($(CONFIG_SLIP_COMPRESSED),y)
-  obj-$(CONFIG_SLIP) += slhc.o
-endif
+obj-$(CONFIG_SLHC) += slhc.o
 
 obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_IFB) += ifb.o
