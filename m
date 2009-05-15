From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 2/5] de600: convert PRINTK() to pr_debug()
Date: Sat, 16 May 2009 00:22:39 +0400
Message-ID: <1242418962-1272-2-git-send-email-a.beregalov@gmail.com>
References: <1242418962-1272-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:11594 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbZEOUXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 16:23:07 -0400
Received: by fg-out-1718.google.com with SMTP id d23so204368fga.17
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:23:07 -0700 (PDT)
In-Reply-To: <1242418962-1272-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove de600_debug as it is not needed.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/de600.c |   19 +++----------------
 1 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index de63f1d..c866ca9 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -38,14 +38,6 @@ static const char version[] = "de600.c: $Revision: 1.41-2.5 $,  Bjorn Ekwall (bj
 /* Add more time here if your adapter won't work OK: */
 #define DE600_SLOW_DOWN	udelay(delay_time)
 
-/* use 0 for production, 1 for verification, >2 for debug */
-#ifdef DE600_DEBUG
-#define PRINTK(x) if (de600_debug >= 2) printk x
-#else
-#define DE600_DEBUG 0
-#define PRINTK(x) /**/
-#endif
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -67,10 +59,6 @@ static const char version[] = "de600.c: $Revision: 1.41-2.5 $,  Bjorn Ekwall (bj
 
 #include "de600.h"
 
-static unsigned int de600_debug = DE600_DEBUG;
-module_param(de600_debug, int, 0);
-MODULE_PARM_DESC(de600_debug, "DE-600 debug level (0-2)");
-
 static unsigned int check_lost = 1;
 module_param(check_lost, bool, 0);
 MODULE_PARM_DESC(check_lost, "If set then check for unplugged de600");
@@ -193,7 +181,7 @@ static int de600_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Start real output */
-	PRINTK(("de600_start_xmit:len=%d, page %d/%d\n", skb->len, tx_fifo_in, free_tx_pages));
+	pr_debug("de600_start_xmit:len=%d, page %d/%d\n", skb->len, tx_fifo_in, free_tx_pages);
 
 	if ((len = skb->len) < RUNT)
 		len = RUNT;
@@ -259,7 +247,7 @@ static irqreturn_t de600_interrupt(int irq, void *dev_id)
 	irq_status = de600_read_status(dev);
 
 	do {
-		PRINTK(("de600_interrupt (%02X)\n", irq_status));
+		pr_debug("de600_interrupt (%02X)\n", irq_status);
 
 		if (irq_status & RX_GOOD)
 			de600_rx_intr(dev);
@@ -407,8 +395,7 @@ static struct net_device * __init de600_probe(void)
 
 	printk(KERN_INFO "%s: D-Link DE-600 pocket adapter", dev->name);
 	/* Alpha testers must have the version number to report bugs. */
-	if (de600_debug > 1)
-		printk(version);
+	pr_debug("%s", version);
 
 	/* probe for adapter */
 	err = -ENODEV;
-- 
1.6.3

