From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH 2/2] mac8390: raise error logging priority
Date: Tue, 1 Jun 2010 22:18:56 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1006011739160.299@localhost>
References: <alpine.LNX.2.00.1005312011210.469@nippy.intranet> <20100531.043056.258120791.davem@davemloft.net> <alpine.OSX.2.00.1005312244520.1490@localhost> <20100531.060225.68146363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: geert@linux-m68k.org, joe@perches.com, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100531.060225.68146363.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Log error conditions using KERN_ERR priority.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

---

This patch doesn't address the KERN_INFO messages conditional on ei_debug. 
I don't know how those can be improved to the satisfaction of all 
interested parties.

These two patches should be applied in sequence.

Index: linux-2.6.34/drivers/net/mac8390.c
===================================================================
--- linux-2.6.34.orig/drivers/net/mac8390.c	2010-06-01 20:22:23.000000000 +1000
+++ linux-2.6.34/drivers/net/mac8390.c	2010-06-01 20:22:25.000000000 +1000
@@ -556,7 +556,7 @@ static int __init mac8390_initdev(struct
 	case MAC8390_APPLE:
 		switch (mac8390_testio(dev->mem_start)) {
 		case ACCESS_UNKNOWN:
-			pr_info("Don't know how to access card memory!\n");
+			pr_err("Don't know how to access card memory!\n");
 			return -ENODEV;
 			break;
 
@@ -648,7 +648,7 @@ static int mac8390_open(struct net_devic
 	__ei_open(dev);
 	err = request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev);
 	if (err)
-		pr_info("%s: unable to get IRQ %d\n", dev->name, dev->irq);
+		pr_err("%s: unable to get IRQ %d\n", dev->name, dev->irq);
 	return err;
 }
 
