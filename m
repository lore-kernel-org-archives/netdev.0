From: Markus Brunner <super.firetwister@googlemail.com>
Subject: [PATCH] smc911x irq sense request and MPR2 board support
Date: Mon, 20 Aug 2007 08:36:50 +0200
Message-ID: <200708200836.51182.super.firetwister@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mark Jonas <toertel@gmail.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:20380 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbXHTGch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 02:32:37 -0400
Received: by nf-out-0910.google.com with SMTP id g13so562536nfb
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2007 23:32:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this are the changes to the smc911x driver, which were necessary
to get it running on the Magic Panel R2 (smsc9115).
It is a SH3-DSP based board. The other patches are available on 
the linuxsh-dev mailinglist.
http://marc.info/?l=linuxsh-dev&r=1&b=200708&w=2

It was necessary to set the irq sense to low level.
Therefor the SMC_IRQ_SENSE define was added.
How are the chances for inclusion in 2.6.24?

Signed-off by: Markus Brunner <super.firetwister@gmail.com>
Signed-off by: Mark Jonas <toertel@gmail.com>
---
 Kconfig   |    2 +-
 smc911x.c |    2 +-
 smc911x.h |    6 ++++++
 3 files changed, 8 insertions(+), 2 deletions(-)

--- sh-2.6-intc/drivers/net/Kconfig	2007-08-02 07:05:16.000000000 +0200
+++ sh-2.6/drivers/net/Kconfig	2007-08-03 09:46:20.000000000 +0200
@@ -944,7 +944,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA
+	depends on ARCH_PXA || SUPERH
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
--- sh-2.6-intc/drivers/net/smc911x.c	2007-07-04 21:46:34.000000000 +0200
+++ sh-2.6/drivers/net/smc911x.c	2007-08-14 10:43:16.000000000 +0200
@@ -2084,7 +2084,7 @@ static int __init smc911x_probe(struct n
 
 	/* Grab the IRQ */
 	retval = request_irq(dev->irq, &smc911x_interrupt,
-			IRQF_SHARED | IRQF_TRIGGER_FALLING, dev->name, dev);
+			IRQF_SHARED | SMC_IRQ_SENSE, dev->name, dev);
 	if (retval)
 		goto err_out;
 
--- sh-2.6-intc/drivers/net/smc911x.h	2007-07-04 21:46:34.000000000 +0200
+++ sh-2.6/drivers/net/smc911x.h	2007-08-10 13:16:34.000000000 +0200
@@ -36,6 +36,12 @@
   #define SMC_USE_PXA_DMA	1
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE IRQF_TRIGGER_FALLING
+#elif CONFIG_SH_MAGIC_PANEL_R2
+  #define SMC_USE_SH_DMA	0
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE IRQF_TRIGGER_LOW
 #endif
