From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(1/20): Add mv643xx_enet support for PPC Pegasos platform
Date: Mon, 28 Mar 2005 16:40:53 -0700
Message-ID: <20050328234053.GA29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Set SA_SHIRQ flag on call to request_irq()

Add MV643XX_ETH dependency on PPC_MULTIPLATFORM

Signed-off-by: Nicolas DET <nd@bplan-gmbh.de>
Signed-off-by: Sven Luther <sl@bplan-gmbh.de>
Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -668,7 +668,7 @@
 	spin_lock_irq(&mp->lock);
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
-			SA_INTERRUPT | SA_SAMPLE_RANDOM, dev->name, dev);
+			SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
 
 	if (err) {
 		printk(KERN_ERR "Can not assign IRQ number to MV643XX_eth%d\n",
Index: linux-2.5-enet/drivers/net/Kconfig
===================================================================
--- linux-2.5-enet.orig/drivers/net/Kconfig
+++ linux-2.5-enet/drivers/net/Kconfig
@@ -2066,7 +2066,7 @@
 
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
-	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360 || MOMENCO_OCELOT_3
+	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360 || MOMENCO_OCELOT_3 || PPC_MULTIPLATFORM
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV643XX
 	  chipset which is used in the Momenco Ocelot C and Jaguar ATX and
