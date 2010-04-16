From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] mac8390: fix pr_info() calls, was Re: another cleanup patch
 gone wrong
Date: Fri, 16 Apr 2010 13:45:28 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1004161323340.271@localhost>
References: <alpine.OSX.2.00.1004161214270.271@localhost> <20100415.200113.215578006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.telegraphics.com.au ([204.15.192.19]:37779 "EHLO
	mail.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757523Ab0DPDpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 23:45:32 -0400
In-Reply-To: <20100415.200113.215578006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 15 Apr 2010, David Miller wrote:

> >> -                       printk("Don't know how to access card memory!\n");
> >> +                       pr_info("Don't know how to access card memory!\n");
> > 
> > No, this is pr_err. The driver sets dev->mem_start expecting it to work, 
> > obviously.
> 
> It was an unspecified printk() so Joe's conversion is equal
> and that's a good way for him to have made these changes.

Seems to me that the code went from unspecified to wrong. But I can see 
your point of view.

> If we want to mark this as KERN_ERR or whatever, that's entirely a 
> seperate change.
>
> I think your objections to Joe's changes are completely uncalled for and 
> his changes were good ones.

Here's a patch, both uncalled-for and untested.


Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

--- a/drivers/net/mac8390.c	2010-04-16 13:31:04.000000000 +1000
+++ b/drivers/net/mac8390.c	2010-04-16 13:35:06.000000000 +1000
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
+		pr_debug("reset not supported\n");
 	return;
 }
 
@@ -668,7 +668,7 @@
 {
 	unsigned char *target = nubus_slot_addr(IRQ2SLOT(dev->irq));
 	if (ei_debug > 1)
-		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
+		pr_debug("Need to reset the NS8390 t=%lu...", jiffies);
 	ei_status.txing = 0;
 	target[0xC0000] = 0;
 	if (ei_debug > 1)
