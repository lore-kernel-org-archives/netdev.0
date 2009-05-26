From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] mac8390: use printk MAC address format
Date: Tue, 26 May 2009 12:52:47 +1000 (EST)
Message-ID: <Pine.LNX.4.64.0905261250300.22373@loopy.telegraphics.com.au>
References: <Pine.LNX.4.64.0905260136450.18180@loopy.telegraphics.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0905260136450.18180@loopy.telegraphics.com.au>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


mac8390: use printk MAC address format

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

---

Resending with netdev list CC'd as requested.


--- linux-2.6.29.orig/drivers/net/mac8390.c	2009-03-24 10:12:14.000000000 +1100
+++ linux-2.6.29/drivers/net/mac8390.c	2009-05-22 01:48:07.000000000 +1000
@@ -620,19 +620,12 @@
 
 	/* Good, done, now spit out some messages */
 	printk(KERN_INFO "%s: %s in slot %X (type %s)\n",
-		   dev->name, ndev->board->name, ndev->board->slot, cardname[type]);
-	printk(KERN_INFO "MAC ");
-	{
-		int i;
-		for (i = 0; i < 6; i++) {
-			printk("%2.2x", dev->dev_addr[i]);
-			if (i < 5)
-				printk(":");
-		}
-	}
-	printk(" IRQ %d, %d KB shared memory at %#lx,  %d-bit access.\n",
-		   dev->irq, (int)((dev->mem_end - dev->mem_start)/0x1000) * 4,
-		   dev->mem_start, access_bitmode?32:16);
+	       dev->name, ndev->board->name, ndev->board->slot, cardname[type]);
+	printk(KERN_INFO
+	       "MAC %pM IRQ %d, %d KB shared memory at %#lx, %d-bit access.\n",
+	       dev->dev_addr, dev->irq,
+	       (unsigned int)(dev->mem_end - dev->mem_start) >> 10,
+	       dev->mem_start, access_bitmode ? 32 : 16);
 	return 0;
 }
 
