From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v3 11/12] DM9000: Remove DEFAULT_TRIGGER for request_irq() flags.
Date: Tue, 24 Jun 2008 22:16:07 +0100
Message-ID: <20080624211906.330282002@fluff.org.uk>
References: <20080624211556.566149406@fluff.org.uk>
Cc: jeff@garzik.org, laurentp@cse-semaphore.com,
	Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:64004 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753262AbYFXVTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 17:19:07 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-remove-default-trigger.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently all but one user (AT91SAM9261EK) of the dm9000
driver passes their IRQ flags through the resources attached
to the platform device. This means we can remove the use
of DEFAULT_TRIGGER as the blackfin machines all seem to
have their triggers set properly.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc7-next20080624/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc7-next20080624.orig/drivers/net/dm9000.c	2008-06-24 22:09:43.000000000 +0100
+++ linux-2.6.26-rc7-next20080624/drivers/net/dm9000.c	2008-06-24 22:09:44.000000000 +0100
@@ -54,9 +54,6 @@
 #define writesb	outsb
 #define writesw	outsw
 #define writesl	outsl
-#define DEFAULT_TRIGGER IRQF_TRIGGER_HIGH
-#else
-#define DEFAULT_TRIGGER (0)
 #endif
 
 /*
@@ -1014,11 +1011,9 @@ dm9000_open(struct net_device *dev)
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
