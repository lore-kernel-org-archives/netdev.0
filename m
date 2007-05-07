From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 07 May 2007 02:06:56 +0200
Message-ID: <m3y7k1biov.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:35105 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712AbXEGAG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2007 20:06:59 -0400
In-Reply-To: <m3abwhcy74.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Mon, 07 May 2007 01:46:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow enabling WAN drivers without selecting generic HDLC first,
HDLC will be selected automatically.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 8897f53..3a2fe82 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -171,7 +171,8 @@ comment "X.25/LAPB support is disabled"
 
 config PCI200SYN
 	tristate "Goramo PCI200SYN support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	help
 	  Driver for PCI200SYN cards by Goramo sp. j.
 
@@ -185,7 +186,8 @@ config PCI200SYN
 
 config WANXL
 	tristate "SBE Inc. wanXL support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	help
 	  Driver for wanXL PCI cards by SBE Inc.
 
@@ -208,7 +210,8 @@ config WANXL_BUILD_FIRMWARE
 
 config PC300
 	tristate "Cyclades-PC300 support (RS-232/V.35, X.21, T1/E1 boards)"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	---help---
 	  Driver for the Cyclades-PC300 synchronous communication boards.
 
@@ -225,19 +228,21 @@ config PC300
 
 config PC300_MLPPP
 	bool "Cyclades-PC300 MLPPP support"
-	depends on PC300 && PPP_MULTILINK && PPP_SYNC_TTY && HDLC_PPP
+	depends on PC300 && PPP_MULTILINK && PPP_SYNC_TTY
+	select HDLC_PPP
 	help
 	  Multilink PPP over the PC300 synchronous communication boards.
 
 comment "Cyclades-PC300 MLPPP support is disabled."
-	depends on WAN && HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on WAN && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n)
 
 comment "Refer to the file README.mlppp, provided by PC300 package."
-	depends on WAN && HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on WAN && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n)
 
 config PC300TOO
 	tristate "Cyclades PC300 RSV/X21 alternative support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	help
 	  Alternative driver for PC300 RSV/X21 PCI cards made by
 	  Cyclades, Inc. If you have such a card, say Y here and see
@@ -250,7 +255,8 @@ config PC300TOO
 
 config N2
 	tristate "SDL RISCom/N2 support"
-	depends on HDLC && ISA
+	depends on ISA
+	select HDLC
 	help
 	  Driver for RISCom/N2 single or dual channel ISA cards by
 	  SDL Communications Inc.
@@ -267,7 +273,8 @@ config N2
 
 config C101
 	tristate "Moxa C101 support"
-	depends on HDLC && ISA
+	depends on ISA
+	select HDLC
 	help
 	  Driver for C101 SuperSync ISA cards by Moxa Technologies Co., Ltd.
 
@@ -281,7 +288,8 @@ config C101
 
 config FARSYNC
 	tristate "FarSync T-Series support"
-	depends on HDLC && PCI
+	depends on PCI
+	select HDLC
 	---help---
 	  Support for the FarSync T-Series X.21 (and V.35/V.24) cards by
 	  FarSite Communications Ltd.
@@ -300,7 +308,8 @@ config FARSYNC
 
 config DSCC4
 	tristate "Etinc PCISYNC serial board support"
-	depends on HDLC && PCI && m
+	depends on PCI && m
+	select HDLC
 	help
 	  Driver for Etinc PCISYNC boards based on the Infineon (ex. Siemens)
 	  DSCC4 chipset.
