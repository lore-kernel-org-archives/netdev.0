From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: [3/8] orinoco: Use mdelay()/ssleep() instead of more complex delays
Date: Wed, 12 Jan 2005 16:26:30 +1100
Message-ID: <20050112052630.GD30426@localhost.localdomain>
References: <20050112052352.GA30426@localhost.localdomain> <20050112052434.GB30426@localhost.localdomain> <20050112052543.GC30426@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orinoco-devel@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263091AbVALF35@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050112052543.GC30426@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use mdelay() or ssleep() instead of various silly more complicated
ways of delaying in the orinoco driver.

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco_pci.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_pci.c	2005-01-12 15:13:18.819073992 +1100
+++ working-2.6/drivers/net/wireless/orinoco_pci.c	2005-01-12 15:15:33.137654464 +1100
@@ -151,19 +151,11 @@
 
 	/* Assert the reset until the card notice */
 	hermes_write_regn(hw, PCI_COR, HERMES_PCI_COR_MASK);
-	timeout = jiffies + (HERMES_PCI_COR_ONT * HZ / 1000);
-	while(time_before(jiffies, timeout)) {
-		mdelay(1);
-	}
-	//mdelay(HERMES_PCI_COR_ONT);
+	mdelay(HERMES_PCI_COR_ONT);
 
 	/* Give time for the card to recover from this hard effort */
 	hermes_write_regn(hw, PCI_COR, 0x0000);
-	timeout = jiffies + (HERMES_PCI_COR_OFFT * HZ / 1000);
-	while(time_before(jiffies, timeout)) {
-		mdelay(1);
-	}
-	//mdelay(HERMES_PCI_COR_OFFT);
+	mdelay(HERMES_PCI_COR_OFFT);
 
 	/* The card is ready when it's no longer busy */
 	timeout = jiffies + (HERMES_PCI_COR_BUSYT * HZ / 1000);
Index: working-2.6/drivers/net/wireless/orinoco_plx.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_plx.c	2005-01-12 15:13:18.821073688 +1100
+++ working-2.6/drivers/net/wireless/orinoco_plx.c	2005-01-12 15:15:33.138654312 +1100
@@ -356,8 +356,7 @@
 static void __exit orinoco_plx_exit(void)
 {
 	pci_unregister_driver(&orinoco_plx_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	ssleep(1);
 }
 
 module_init(orinoco_plx_init);
Index: working-2.6/drivers/net/wireless/orinoco_tmd.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_tmd.c	2005-01-12 15:13:18.820073840 +1100
+++ working-2.6/drivers/net/wireless/orinoco_tmd.c	2005-01-12 15:16:05.897674184 +1100
@@ -225,8 +225,7 @@
 static void __exit orinoco_tmd_exit(void)
 {
 	pci_unregister_driver(&orinoco_tmd_driver);
-	current->state = TASK_UNINTERRUPTIBLE;
-	schedule_timeout(HZ);
+	ssleep(1);
 }
 
 module_init(orinoco_tmd_init);


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
