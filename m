From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] macmace, macsonic: cleanup
Date: Wed, 14 Sep 2011 03:30:25 +1000 (EST)
Message-ID: <alpine.LNX.2.00.1109140317300.20729@nippy.intranet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We check ether_type before registering the platform device in 
arch/m68k/mac/config.c. Doing the same test again in the driver is 
redundant so remove it.

Multiple probes should not happen since the conversion to platform devices,
so lose that test too.

Then macmace.c need not include macintosh.h, so remove that and irq.h and 
include linux/interrupt.h explicitly.

Tested on PowerBook 520, Quadra 660av, LC 630.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Index: linux-m68k/drivers/net/macmace.c
===================================================================
--- linux-m68k.orig/drivers/net/macmace.c	2011-09-14 02:37:26.000000000 +1000
+++ linux-m68k/drivers/net/macmace.c	2011-09-14 02:39:08.000000000 +1000
@@ -31,9 +31,8 @@
 #include <linux/dma-mapping.h>
 #include <linux/platform_device.h>
 #include <linux/gfp.h>
+#include <linux/interrupt.h>
 #include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/macintosh.h>
 #include <asm/macints.h>
 #include <asm/mac_psc.h>
 #include <asm/page.h>
@@ -203,14 +202,8 @@ static int __devinit mace_probe(struct p
 	unsigned char *addr;
 	struct net_device *dev;
 	unsigned char checksum = 0;
-	static int found = 0;
 	int err;
 
-	if (found || macintosh_config->ether_type != MAC_ETHER_MACE)
-		return -ENODEV;
-
-	found = 1;	/* prevent 'finding' one on every device probe */
-
 	dev = alloc_etherdev(PRIV_BYTES);
 	if (!dev)
 		return -ENOMEM;
Index: linux-m68k/drivers/net/macsonic.c
===================================================================
--- linux-m68k.orig/drivers/net/macsonic.c	2011-09-14 02:38:53.000000000 +1000
+++ linux-m68k/drivers/net/macsonic.c	2011-09-14 02:39:08.000000000 +1000
@@ -312,22 +312,13 @@ static void __devinit mac_onboard_sonic_
 
 static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
 {
-	/* Bwahahaha */
-	static int once_is_more_than_enough;
 	struct sonic_local* lp = netdev_priv(dev);
 	int sr;
 	int commslot = 0;
 
-	if (once_is_more_than_enough)
-		return -ENODEV;
-	once_is_more_than_enough = 1;
-
 	if (!MACH_IS_MAC)
 		return -ENODEV;
 
-	if (macintosh_config->ether_type != MAC_ETHER_SONIC)
-		return -ENODEV;
-
 	printk(KERN_INFO "Checking for internal Macintosh ethernet (SONIC).. ");
 
 	/* Bogus probing, on the models which may or may not have
