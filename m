From: Daniel Mack <daniel@caiaq.de>
Subject: [REPOST] [PATCH] enable SMC911X for ARCH_MX3
Date: Tue, 29 Jan 2008 23:08:01 +0100
Message-ID: <20080129220801.GA18762@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:34640 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbYA2WIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 17:08:07 -0500
Received: from localhost (localhost [127.0.0.1])
	by buzzloop.caiaq.de (Postfix) with ESMTP id A5CAC7F4020
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 23:08:05 +0100 (CET)
Received: from buzzloop.caiaq.de ([127.0.0.1])
	by localhost (buzzloop.caiaq.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id U4tyi+mpwIA3 for <netdev@vger.kernel.org>;
	Tue, 29 Jan 2008 23:08:02 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch enables SMX911X support for Freescale's MX3 platforms.

Signed-off-by: Daniel Mack <daniel@caiaq.de>


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6cde4ed..1011735 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -926,7 +926,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SH_MAGIC_PANEL_R2
+	depends on ARCH_PXA || ARCH_MX3 || SH_MAGIC_PANEL_R2
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index d04e4fa..2278408 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -37,6 +37,11 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
+#elif defined(CONFIG_ARCH_MX3)
+  #define SMC_USE_PXA_DMA	0
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
 #elif defined(CONFIG_SH_MAGIC_PANEL_R2)
   #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0

