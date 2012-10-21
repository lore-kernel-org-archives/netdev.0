From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v2 1/3] net/cadence: get rid of HAVE_NET_MACB
Date: Sun, 21 Oct 2012 23:57:01 +0200
Message-ID: <1350856623-9819-2-git-send-email-manabian@gmail.com>
References: <1350856623-9819-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:36864 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617Ab2JUV5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 17:57:25 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so1238166lag.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 14:57:23 -0700 (PDT)
In-Reply-To: <1350856623-9819-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb is a platform driver and there is nothing that prevents
this driver from being built on non-ARM/AVR32 platforms.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 arch/arm/mach-at91/Kconfig           | 4 ----
 arch/avr32/Kconfig                   | 1 -
 drivers/net/ethernet/cadence/Kconfig | 5 -----
 3 files changed, 10 deletions(-)

diff --git a/arch/arm/mach-at91/Kconfig b/arch/arm/mach-at91/Kconfig
index d846b6e..72020fb 100644
--- a/arch/arm/mach-at91/Kconfig
+++ b/arch/arm/mach-at91/Kconfig
@@ -45,7 +45,6 @@ config SOC_AT91RM9200
 config SOC_AT91SAM9260
 	bool "AT91SAM9260, AT91SAM9XE or AT91SAM9G20"
 	select HAVE_AT91_DBGU0
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 	help
 	  Select this if you are using one of Atmel's AT91SAM9260, AT91SAM9XE
@@ -63,7 +62,6 @@ config SOC_AT91SAM9263
 	bool "AT91SAM9263"
 	select HAVE_AT91_DBGU1
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 
 config SOC_AT91SAM9RL
@@ -76,7 +74,6 @@ config SOC_AT91SAM9G45
 	bool "AT91SAM9G45 or AT91SAM9M10 families"
 	select HAVE_AT91_DBGU1
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 	help
 	  Select this if you are using one of Atmel's AT91SAM9G45 family SoC.
@@ -86,7 +83,6 @@ config SOC_AT91SAM9X5
 	bool "AT91SAM9x5 family"
 	select HAVE_AT91_DBGU0
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 	help
 	  Select this if you are using one of Atmel's AT91SAM9x5 family SoC.
diff --git a/arch/avr32/Kconfig b/arch/avr32/Kconfig
index 06e73bf..09f9fa8 100644
--- a/arch/avr32/Kconfig
+++ b/arch/avr32/Kconfig
@@ -80,7 +80,6 @@ config PLATFORM_AT32AP
 	select ARCH_REQUIRE_GPIOLIB
 	select GENERIC_ALLOCATOR
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 
 #
 # CPU types
diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 57f78abe..5d1ea30 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -2,13 +2,9 @@
 # Atmel device configuration
 #
 
-config HAVE_NET_MACB
-	bool
-
 config NET_CADENCE
 	bool "Cadence devices"
 	default y
-	depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
@@ -34,7 +30,6 @@ config ARM_AT91_ETHER
 
 config MACB
 	tristate "Cadence MACB/GEM support"
-	depends on HAVE_NET_MACB
 	select PHYLIB
 	---help---
 	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
-- 
1.7.12.4
