From: Daniel Mack <daniel@caiaq.de>
Subject: DM9000_IRQ_FLAGS
Date: Tue, 11 Dec 2007 20:18:23 +0100
Message-ID: <20071211191823.GD15295@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:47755 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbXLKTS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 14:18:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by buzzloop.caiaq.de (Postfix) with ESMTP id 322307F4021
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 20:18:27 +0100 (CET)
Received: from buzzloop.caiaq.de ([127.0.0.1])
	by localhost (buzzloop.caiaq.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DOQ98YiV5Xye for <netdev@vger.kernel.org>;
	Tue, 11 Dec 2007 20:18:24 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

on Toradex' Colibri, a PXA270 based board with a DM9000 ethernet
controller, this driver won't work due to unsuitable DM9000_IRQ_FLAGS.
If I understood the code behind request_irq() correctly, it's not
recommended to register an IRQ without any of the IRQT_* flags set.

Is there any concerns about applying the patch below?

Best regards,
Daniel

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 3286d2a..6a20a54 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -66,6 +66,7 @@
 #include <linux/dm9000.h>
 #include <linux/delay.h>
 #include <linux/platform_device.h>
+#include <linux/irq.h>
 
 #include <asm/delay.h>
 #include <asm/irq.h>
@@ -113,7 +114,7 @@
 #define writesl	outsl
 #define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQF_TRIGGER_HIGH)
 #else
-#define DM9000_IRQ_FLAGS	IRQF_SHARED
+#define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQT_RISING)
 #endif
 
 /*
