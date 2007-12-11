From: Daniel Mack <daniel@caiaq.de>
Subject: [PATCH] enable SMC911X for ARCH_MX3
Date: Tue, 11 Dec 2007 20:12:33 +0100
Message-ID: <20071211191233.GC15295@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="aVD9QWMuhilNxW9f"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:45318 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbXLKTVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 14:21:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by buzzloop.caiaq.de (Postfix) with ESMTP id CA22E7F401F
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 20:12:36 +0100 (CET)
Received: from buzzloop.caiaq.de ([127.0.0.1])
	by localhost (buzzloop.caiaq.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jqNVYSfz3JCk for <netdev@vger.kernel.org>;
	Tue, 11 Dec 2007 20:12:33 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--aVD9QWMuhilNxW9f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

this patch enables SMX911X support for Freescale's MX3 platforms.

Signed-off-by: Daniel Mack <daniel@caiaq.de>



--aVD9QWMuhilNxW9f
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="smc911x-mx3.diff"

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

--aVD9QWMuhilNxW9f--
