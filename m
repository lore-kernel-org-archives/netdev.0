From: aris@cathedrallabs.org (Aristeu Sergio Rozanski Filho)
Subject: [patch] ne.c: print info message after register_netdev()
Date: Mon, 24 May 2004 15:49:18 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524184918.GB15546@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jRHKVT23PllUwdXP"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hi,
	this patch avoids printing eth%d everytime a card is detected.

-- 
Aristeu

P.S:
	I'm not sure if this is the right list to send this and I'm not
	subscribed to this list either. so, please cc me for any
	comments.


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ne-print.diff"

--- 2.6-clean/drivers/net/ne.c	2004-05-09 23:32:29.000000000 -0300
+++ 2.6/drivers/net/ne.c	2004-05-24 13:31:38.000000000 -0300
@@ -477,9 +477,6 @@ static int __init ne_probe1(struct net_d
 		dev->dev_addr[i] = SA_prom[i];
 	}
 
-	printk("\n%s: %s found at %#x, using IRQ %d.\n",
-		dev->name, name, ioaddr, dev->irq);
-
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
 	ei_status.stop_page = stop_page;
@@ -795,6 +792,10 @@ int init_module(void)
 		dev->base_addr = io[this_dev];
 		if (do_ne_probe(dev) == 0) {
 			if (register_netdev(dev) == 0) {
+				printk("\n%s: %s found at %#lx, using IRQ %d.\n",
+					dev->name, ei_status.name,
+					dev->base_addr, dev->irq);
+
 				dev_ne[found++] = dev;
 				continue;
 			}

--jRHKVT23PllUwdXP--
