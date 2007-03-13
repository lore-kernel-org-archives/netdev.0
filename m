From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] AX.25 Kconfig and docs updates and fixes
Date: Tue, 13 Mar 2007 11:55:38 +0000
Message-ID: <20070313115537.GA10921@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:19896 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022263AbXCML5c (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 1 other); Tue, 13 Mar 2007 11:57:32 +0000
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 o The AX.25 Howto is unmaintained since several years.  I've replaced it
   with a wiki at http://www.linux-ax25.org which provides more uptodate
   information.
 o Change default for AX25_DAMA_SLAVE to Y.  AX25_DAMA_SLAVE only compiles
   in support for DAMA but doesn't activate it.  I hope this gets Linux
   distributions to ship their AX.25 kernels with AX25_DAMA_SLAVE enabled.
   The price for this would be very small.
 o Delete historic changelog from comments, that's what SCM systems are
   meant to do.
 o ---help--- in Kconfig looks so yellingly eye insulting.  Use just help.
 o Rewrite the commented out piece of old Linux 2.4 configuration language
   to Kconfig for consistency.
 o Fixup dependencies.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/Documentation/networking/ax25.txt b/Documentation/networking/ax25.txt
index 37c25b0..8257dbf 100644
--- a/Documentation/networking/ax25.txt
+++ b/Documentation/networking/ax25.txt
@@ -1,16 +1,10 @@
 To use the amateur radio protocols within Linux you will need to get a
-suitable copy of the AX.25 Utilities. More detailed information about these
-and associated programs can be found on http://zone.pspt.fi/~jsn/.
-
-For more information about the AX.25, NET/ROM and ROSE protocol stacks, see
-the AX25-HOWTO written by Terry Dawson <terry@perf.no.itg.telstra.com.au>
-who is also the AX.25 Utilities maintainer.
+suitable copy of the AX.25 Utilities. More detailed information about
+AX.25, NET/ROM and ROSE, associated programs and and utilities can be
+found on http://www.linux-ax25.org.
 
 There is an active mailing list for discussing Linux amateur radio matters
-called linux-hams. To subscribe to it, send a message to
+called linux-hams@vger.kernel.org. To subscribe to it, send a message to
 majordomo@vger.kernel.org with the words "subscribe linux-hams" in the body
-of the message, the subject field is ignored.
-
-Jonathan G4KLX
-
-g4klx@g4klx.demon.co.uk
+of the message, the subject field is ignored.  You don't need to be
+subscribed to post but of course that means you might miss an answer.
diff --git a/net/ax25/Kconfig b/net/ax25/Kconfig
index a8993a0..43dd86f 100644
--- a/net/ax25/Kconfig
+++ b/net/ax25/Kconfig
@@ -1,30 +1,27 @@
 #
 # Amateur Radio protocols and AX.25 device configuration
 #
-# 19971130	Now in an own category to make correct compilation of the
-#		AX.25 stuff easier...
-#		Joerg Reuter DL1BKE <jreuter@yaina.de>
-# 19980129	Moved to net/ax25/Config.in, sourcing device drivers.
 
 menuconfig HAMRADIO
 	depends on NET
 	bool "Amateur Radio support"
 	help
 	  If you want to connect your Linux box to an amateur radio, answer Y
-	  here. You want to read <http://www.tapr.org/tapr/html/pkthome.html> and
-	  the AX25-HOWTO, available from <http://www.tldp.org/docs.html#howto>.
+	  here. You want to read <http://www.tapr.org/tapr/html/pkthome.html>
+	  and more specifically about AX.25 on Linux
+	  <http://www.linux-ax25.org/>.
 
 	  Note that the answer to this question won't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
 	  the questions about amateur radio.
 
 comment "Packet Radio protocols"
-	depends on HAMRADIO && NET
+	depends on HAMRADIO
 
 config AX25
 	tristate "Amateur Radio AX.25 Level 2 protocol"
-	depends on HAMRADIO && NET
-	---help---
+	depends on HAMRADIO
+	help
 	  This is the protocol used for computer communication over amateur
 	  radio. It is either used by itself for point-to-point links, or to
 	  carry other protocols such as tcp/ip. To use it, you need a device
@@ -52,6 +49,7 @@ config AX25
 
 config AX25_DAMA_SLAVE
 	bool "AX.25 DAMA Slave support"
+	default y
 	depends on AX25
 	help
 	  DAMA is a mechanism to prevent collisions when doing AX.25
@@ -59,23 +57,38 @@ config AX25_DAMA_SLAVE
 	  from clients (called "slaves") and redistributes it to other slaves.
 	  If you say Y here, your Linux box will act as a DAMA slave; this is
 	  transparent in that you don't have to do any special DAMA
-	  configuration. (Linux cannot yet act as a DAMA server.) If unsure,
-	  say N.
+	  configuration. Linux cannot yet act as a DAMA server.  This option
+	  only compiles DAMA slave support into the kernel.  It still needs to
+	  be enabled at runtime.  For more about DAMA see
+	  <http://www.linux-ax25.org>.  If unsure, say Y.
+
+# placeholder until implemented
+config AX25_DAMA_MASTER
+	bool 'AX.25 DAMA Master support'
+	depends on AX25_DAMA_SLAVE && BROKEN
+	help
+	  DAMA is a mechanism to prevent collisions when doing AX.25
+	  networking. A DAMA server (called "master") accepts incoming traffic
+	  from clients (called "slaves") and redistributes it to other slaves.
+	  If you say Y here, your Linux box will act as a DAMA master; this is
+	  transparent in that you don't have to do any special DAMA
+	  configuration. Linux cannot yet act as a DAMA server.  This option
+	  only compiles DAMA slave support into the kernel.  It still needs to
+	  be explicitly enabled, so if unsure, say Y.
 
-#	 bool '    AX.25 DAMA Master support' CONFIG_AX25_DAMA_MASTER
 config NETROM
 	tristate "Amateur Radio NET/ROM protocol"
 	depends on AX25
-	---help---
+	help
 	  NET/ROM is a network layer protocol on top of AX.25 useful for
 	  routing.
 
 	  A comprehensive listing of all the software for Linux amateur radio
 	  users as well as information about how to configure an AX.25 port is
-	  contained in the AX25-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>. You also might want to
-	  check out the file <file:Documentation/networking/ax25.txt>. More
-	  information about digital amateur radio in general is on the WWW at
+	  contained in the Linux Ham Wiki, available from
+	  <http://www.linux-ax25.org>. You also might want to check out the
+	  file <file:Documentation/networking/ax25.txt>. More information about
+	  digital amateur radio in general is on the WWW at
 	  <http://www.tapr.org/tapr/html/pkthome.html>.
 
 	  To compile this driver as a module, choose M here: the
@@ -84,27 +97,25 @@ config NETROM
 config ROSE
 	tristate "Amateur Radio X.25 PLP (Rose)"
 	depends on AX25
-	---help---
+	help
 	  The Packet Layer Protocol (PLP) is a way to route packets over X.25
 	  connections in general and amateur radio AX.25 connections in
 	  particular, essentially an alternative to NET/ROM.
 
 	  A comprehensive listing of all the software for Linux amateur radio
 	  users as well as information about how to configure an AX.25 port is
-	  contained in the AX25-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  You also might want to
-	  check out the file <file:Documentation/networking/ax25.txt>. More
-	  information about digital amateur radio in general is on the WWW at
+	  contained in the Linux Ham Wiki, available from
+	  <http://www.linux-ax25.org>.  You also might want to check out the
+	  file <file:Documentation/networking/ax25.txt>. More information about
+	  digital amateur radio in general is on the WWW at
 	  <http://www.tapr.org/tapr/html/pkthome.html>.
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called rose.
 
-
 menu "AX.25 network device drivers"
-	depends on HAMRADIO && NET && AX25!=n
+	depends on HAMRADIO && AX25
 
 source "drivers/net/hamradio/Kconfig"
 
 endmenu
-
