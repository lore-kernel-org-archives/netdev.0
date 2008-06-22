From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v2 11/11] DM9000: Remove DEFAULT_TRIGGER for request_irq() flags.
Date: Sun, 22 Jun 2008 21:16:56 +0100
Message-ID: <20080622201906.731020286@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk>
Cc: jeff@garzik.org, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:56687 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754812AbYFVUTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:19:08 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-remove-default-trigger.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently all but one user (AT91SAM9261EK) of the dm9000
driver passes their IRQ flags through the resources attached
to the platform device. This means we can remove the use
of DEFAULT_TRIGGER as the blackfin machines all seem to
have their triggers set properly.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt3.orig/drivers/net/dm9000.c	2008-06-22 20:28:55.000000000 +0100
+++ linux-2.6.26-rc6-quilt3/drivers/net/dm9000.c	2008-06-22 20:29:32.000000000 +0100
@@ -54,9 +54,6 @@
 #define writesb	outsb
 #define writesw	outsw
 #define writesl	outsl
-#define DEFAULT_TRIGGER IRQF_TRIGGER_HIGH
-#else
-#define DEFAULT_TRIGGER (0)
 #endif
 
 /*
@@ -1012,11 +1009,9 @@ dm9000_open(struct net_device *dev)
 	/* If there is no IRQ type specified, default to something that
 	 * may work, and tell the user that this is a problem */
 
-	if (irqflags == IRQF_TRIGGER_NONE) {
+	if (irqflags == IRQF_TRIGGER_NONE)
 		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
-		irqflags = DEFAULT_TRIGGER;
-	}
-	
+
 	irqflags |= IRQF_SHARED;
 
 	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
