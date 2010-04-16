From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] mac8390: fix pr_info() calls and change return code
Date: Fri, 16 Apr 2010 14:21:00 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1004161403160.271@localhost>
References: <alpine.OSX.2.00.1004161214270.271@localhost> <20100415.200113.215578006.davem@davemloft.net> <alpine.OSX.2.00.1004161323340.271@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1004161323340.271@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

--- a/drivers/net/mac8390.c	2010-04-16 13:31:04.000000000 +1000
+++ b/drivers/net/mac8390.c	2010-04-16 14:02:29.000000000 +1000
@@ -554,7 +554,7 @@
 	case MAC8390_APPLE:
 		switch (mac8390_testio(dev->mem_start)) {
 		case ACCESS_UNKNOWN:
-			pr_info("Don't know how to access card memory!\n");
+			pr_err("Don't know how to access card memory!\n");
 			return -ENODEV;
 			break;
 
@@ -643,8 +643,8 @@
 {
 	__ei_open(dev);
 	if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
-		pr_info("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
-		return -EAGAIN;
+		pr_err("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
+		return -EBUSY;
 	}
 	return 0;
 }
@@ -660,7 +660,7 @@
 {
 	ei_status.txing = 0;
 	if (ei_debug > 1)
-		pr_info("reset not supported\n");
+		printk(KERN_DEBUG "reset not supported\n");
 	return;
 }
 
@@ -668,11 +668,11 @@
 {
 	unsigned char *target = nubus_slot_addr(IRQ2SLOT(dev->irq));
 	if (ei_debug > 1)
-		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
+		printk(KERN_DEBUG "Need to reset the NS8390 t=%lu...", jiffies);
 	ei_status.txing = 0;
 	target[0xC0000] = 0;
 	if (ei_debug > 1)
-		pr_cont("reset complete\n");
+		printk(KERN_CONT "reset complete\n");
 	return;
 }
 
