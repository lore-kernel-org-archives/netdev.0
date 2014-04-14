From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH v2] net: cadence: Add architecture dependencies
Date: Mon, 14 Apr 2014 15:38:49 +0200
Message-ID: <20140414153849.7138699b@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33496 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753489AbaDNNiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 09:38:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Cadence ethernet chipsets are only used on specific ARM
architectures. Add Kconfig dependencies so that drivers for these
chipsets are only buildable on the relevant architectures.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Changes since v1:
 * Added missing dependency on AVR32, as reported by Nicolas Ferre.

 drivers/net/ethernet/cadence/Kconfig |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-3.15-rc1.orig/drivers/net/ethernet/cadence/Kconfig	2014-03-31 05:40:15.000000000 +0200
+++ linux-3.15-rc1/drivers/net/ethernet/cadence/Kconfig	2014-04-14 15:36:18.141242446 +0200
@@ -4,7 +4,7 @@
 
 config NET_CADENCE
 	bool "Cadence devices"
-	depends on HAS_IOMEM
+	depends on HAS_IOMEM && (ARM || AVR32 || COMPILE_TEST)
 	default y
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
@@ -22,7 +22,7 @@ if NET_CADENCE
 
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
-	depends on HAS_DMA
+	depends on HAS_DMA && (ARCH_AT91RM9200 || COMPILE_TEST)
 	select MACB
 	---help---
 	  If you wish to compile a kernel for the AT91RM9200 and enable
@@ -30,7 +30,7 @@ config ARM_AT91_ETHER
 
 config MACB
 	tristate "Cadence MACB/GEM support"
-	depends on HAS_DMA
+	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCELL || ARCH_ZYNQ || COMPILE_TEST)
 	select PHYLIB
 	---help---
 	  The Cadence MACB ethernet interface is found on many Atmel AT32 and


-- 
Jean Delvare
SUSE L3 Support
