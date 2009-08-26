From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Wed, 26 Aug 2009 12:46:34 +0200
Message-ID: <20090826104634.GA14425@e-circ.dyndns.org>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:49931 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757245AbZHZLBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 07:01:54 -0400
Content-Disposition: inline
In-Reply-To: <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sacha,

I'm using a 2.6.25.
Converting to your platform_device based driver,
I needed to configure the irq (see patch, irq flags).
Looking in the old cs89x0.c, it's done in the driver. Should I have
configured the irq level elsewhere? Or is this patch valid to do?

Kurt

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
---
Index: drivers/net/cirrus-cs89x0.c
===================================================================
--- drivers/net/cirrus-cs89x0.c	(revision 7107)
+++ drivers/net/cirrus-cs89x0.c	(working copy)
@@ -487,7 +487,8 @@
        }
 
        /* install interrupt handler */
-       result = request_irq(ndev->irq, &cirrus_interrupt, 0, ndev->name, ndev);
+       result = request_irq(ndev->irq, &cirrus_interrupt,
+			IRQF_TRIGGER_HIGH, ndev->name, ndev);
        if (result < 0) {
                printk(KERN_ERR "%s: could not register interrupt %d\n",
                       ndev->name, ndev->irq);
