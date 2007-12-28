From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: [PATCH] Make FC, FDDI, HIPPI and TR tristate
Date: Sat, 29 Dec 2007 00:45:12 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:57208 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbXL1XpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 18:45:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn CONFIG_FC, CONFIG_FDDI, CONFIG_HIPPI and CONFIG_TR into tristate
so they can be built as modules. This will allow CONFIG_LLC to be
built as a module too, overall reducing the core kernel image size.
    
$ size vmlinux.previous vmlinux
   text    data     bss     dec     hex filename
2805040  266008  380928 3451976  34ac48 vmlinux.previous
2794603  265620  380928 3441151  3481ff vmlinux

$ l vmlinux.previous vmlinux
-rwxr-xr-x 1 jengelh users 5154214 Dec 29 00:02 vmlinux.previous
-rwxr-xr-x 1 jengelh users 5135974 Dec 29 00:39 vmlinux

Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..934f678 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2638,7 +2638,7 @@ config RIONET_RX_SIZE
 	default "128"
 
 config FDDI
-	bool "FDDI driver support"
+	tristate "FDDI driver support"
 	depends on (PCI || EISA || TC)
 	help
 	  Fiber Distributed Data Interface is a high speed local area network
@@ -2708,7 +2708,7 @@ config SKFP
 	  will be called skfp.  This is recommended.
 
 config HIPPI
-	bool "HIPPI driver support (EXPERIMENTAL)"
+	tristate "HIPPI driver support (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && INET && PCI
 	help
 	  HIgh Performance Parallel Interface (HIPPI) is a 800Mbit/sec and
@@ -3009,7 +3009,7 @@ config SLIP_MODE_SLIP6
 	  over the async ports of a Camtec JNT Pad. If unsure, say N.
 
 config NET_FC
-	bool "Fibre Channel driver support"
+	tristate "Fibre Channel driver support"
 	depends on SCSI && PCI
 	help
 	  Fibre Channel is a high speed serial protocol mainly used to connect
diff --git a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
index e6b2e06..c4137b0 100644
--- a/drivers/net/tokenring/Kconfig
+++ b/drivers/net/tokenring/Kconfig
@@ -4,7 +4,7 @@
 
 # So far, we only have PCI, ISA, and MCA token ring devices
 menuconfig TR
-	bool "Token Ring driver support"
+	tristate "Token Ring driver support"
 	depends on NETDEVICES && !UML
 	depends on (PCI || ISA || MCA || CCW)
 	select LLC

