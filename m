From: Yong Zhang <yong.zhang0@gmail.com>
Subject: [PATCH 34/55] ISDN: irq: Remove IRQF_DISABLED
Date: Thu, 22 Sep 2011 16:59:01 +0800
Message-ID: <1316681962-8217-35-git-send-email-yong.zhang0@gmail.com>
References: <1316681962-8217-1-git-send-email-yong.zhang0@gmail.com>
Cc: tglx@linutronix.de, yong.zhang0@gmail.com,
	Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38518 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab1IVJEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 05:04:44 -0400
In-Reply-To: <1316681962-8217-1-git-send-email-yong.zhang0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit [e58aa3d2: genirq: Run irq handlers with interrupts disabled],
We run all interrupt handlers with interrupts disabled
and we even check and yell when an interrupt handler
returns with interrupts enabled (see commit [b738a50a:
genirq: Warn when handler enables interrupts]).

So now this flag is a NOOP and can be removed.

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
---
 drivers/isdn/hardware/eicon/divasmain.c |    2 +-
 drivers/isdn/sc/init.c                  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index f332b60..8a0a831 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -481,7 +481,7 @@ void __inline__ outpp(void __iomem *addr, word p)
 int diva_os_register_irq(void *context, byte irq, const char *name)
 {
 	int result = request_irq(irq, diva_os_irq_wrapper,
-				 IRQF_DISABLED | IRQF_SHARED, name, context);
+				 IRQF_SHARED, name, context);
 	return (result);
 }
 
diff --git a/drivers/isdn/sc/init.c b/drivers/isdn/sc/init.c
index ca710ab..a3127fb 100644
--- a/drivers/isdn/sc/init.c
+++ b/drivers/isdn/sc/init.c
@@ -336,7 +336,7 @@ static int __init sc_init(void)
 		 */
 		sc_adapter[cinst]->interrupt = irq[b];
 		if (request_irq(sc_adapter[cinst]->interrupt, interrupt_handler,
-				IRQF_DISABLED, interface->id,
+				0, interface->id,
 				(void *)(unsigned long) cinst))
 		{
 			kfree(sc_adapter[cinst]->channel);
-- 
1.7.4.1
