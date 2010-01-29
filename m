From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/13] tulip/pnic2.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:25 -0800
Message-ID: <678a58c1602c2ab4a9955092cd1d7c61afa32d76.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1594 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754115Ab0A2G7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:32 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/pnic2.c |   59 +++++++++++++++++++++++----------------------
 1 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
index d841869..b819766 100644
--- a/drivers/net/tulip/pnic2.c
+++ b/drivers/net/tulip/pnic2.c
@@ -87,8 +87,8 @@ void pnic2_timer(unsigned long data)
 	int next_tick = 60*HZ;
 
 	if (tulip_debug > 3)
-		printk(KERN_INFO"%s: PNIC2 negotiation status %8.8x.\n",
-                    dev->name,ioread32(ioaddr + CSR12));
+		dev_info(&dev->dev, "PNIC2 negotiation status %08x\n",
+			 ioread32(ioaddr + CSR12));
 
 	if (next_tick) {
 		mod_timer(&tp->timer, RUN_AT(next_tick));
@@ -125,8 +125,8 @@ void pnic2_start_nway(struct net_device *dev)
         csr14 |= 0x00001184;
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: Restarting PNIC2 autonegotiation, "
-                      "csr14=%8.8x.\n", dev->name, csr14);
+		printk(KERN_DEBUG "%s: Restarting PNIC2 autonegotiation, csr14=%08x\n",
+		       dev->name, csr14);
 
         /* tell pnic2_lnk_change we are doing an nway negotiation */
 	dev->if_port = 0;
@@ -137,8 +137,8 @@ void pnic2_start_nway(struct net_device *dev)
 
 	tp->csr6 = ioread32(ioaddr + CSR6);
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: On Entry to Nway, "
-                      "csr6=%8.8x.\n", dev->name, tp->csr6);
+		printk(KERN_DEBUG "%s: On Entry to Nway, csr6=%08x\n",
+		       dev->name, tp->csr6);
 
         /* mask off any bits not to touch
          * comment at top of file explains mask value
@@ -181,9 +181,9 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 	int csr12 = ioread32(ioaddr + CSR12);
 
 	if (tulip_debug > 1)
-		printk(KERN_INFO"%s: PNIC2 link status interrupt %8.8x, "
-                       " CSR5 %x, %8.8x.\n", dev->name, csr12,
-                       csr5, ioread32(ioaddr + CSR14));
+		dev_info(&dev->dev,
+			 "PNIC2 link status interrupt %08x,  CSR5 %x, %08x\n",
+			 csr12, csr5, ioread32(ioaddr + CSR14));
 
 	/* If NWay finished and we have a negotiated partner capability.
          * check bits 14:12 for bit pattern 101 - all is good
@@ -215,9 +215,9 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 			else if (negotiated & 0x0020)	dev->if_port = 0;
 			else {
 			     if (tulip_debug > 1)
-		                   printk(KERN_INFO "%s: funny autonegotiate result "
-                                        "csr12 %8.8x advertising %4.4x\n",
-			                 dev->name, csr12, tp->sym_advertise);
+				     dev_info(&dev->dev,
+					      "funny autonegotiate result csr12 %08x advertising %04x\n",
+					      csr12, tp->sym_advertise);
 			     tp->nwayset = 0;
 			     /* so check  if 100baseTx link state is okay */
 			     if ((csr12 & 2) == 0  &&  (tp->sym_advertise & 0x0180))
@@ -231,10 +231,11 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 
 			if (tulip_debug > 1) {
 			       if (tp->nwayset)
-			             printk(KERN_INFO "%s: Switching to %s based on link "
-				    "negotiation %4.4x & %4.4x = %4.4x.\n",
-				     dev->name, medianame[dev->if_port],
-                                     tp->sym_advertise, tp->lpar, negotiated);
+				       dev_info(&dev->dev,
+						"Switching to %s based on link negotiation %04x & %04x = %04x\n",
+						medianame[dev->if_port],
+						tp->sym_advertise, tp->lpar,
+						negotiated);
 			}
 
                         /* remember to turn off bit 7 - autonegotiate
@@ -270,9 +271,9 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 			iowrite32(1, ioaddr + CSR13);
 
 			if (tulip_debug > 2)
-			        printk(KERN_DEBUG "%s:  Setting CSR6 %8.8x/%x CSR12 "
-                                      "%8.8x.\n", dev->name, tp->csr6,
-                                      ioread32(ioaddr + CSR6), ioread32(ioaddr + CSR12));
+			        printk(KERN_DEBUG "%s: Setting CSR6 %08x/%x CSR12 %08x\n",
+				       dev->name, tp->csr6,
+				       ioread32(ioaddr + CSR6), ioread32(ioaddr + CSR12));
 
 			/* now the following actually writes out the
 			 * new csr6 values
@@ -282,9 +283,9 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
                         return;
 
 	        } else {
-	                printk(KERN_INFO "%s: Autonegotiation failed, "
-                                    "using %s, link beat status %4.4x.\n",
-				     dev->name, medianame[dev->if_port], csr12);
+	                dev_info(&dev->dev,
+				 "Autonegotiation failed, using %s, link beat status %04x\n",
+				 medianame[dev->if_port], csr12);
 
                         /* remember to turn off bit 7 - autonegotiate
                          * enable so we don't forget
@@ -339,9 +340,9 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 	        /* we are at 100mb and a potential link change occurred */
 
 		if (tulip_debug > 1)
-			printk(KERN_INFO"%s: PNIC2 %s link beat %s.\n",
-				   dev->name, medianame[dev->if_port],
-				   (csr12 & 2) ? "failed" : "good");
+			dev_info(&dev->dev, "PNIC2 %s link beat %s\n",
+				 medianame[dev->if_port],
+				 (csr12 & 2) ? "failed" : "good");
 
                 /* check 100 link beat */
 
@@ -364,9 +365,9 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 	        /* we are at 10mb and a potential link change occurred */
 
 		if (tulip_debug > 1)
-			printk(KERN_INFO"%s: PNIC2 %s link beat %s.\n",
-				   dev->name, medianame[dev->if_port],
-				   (csr12 & 4) ? "failed" : "good");
+			dev_info(&dev->dev, "PNIC2 %s link beat %s\n",
+				 medianame[dev->if_port],
+				 (csr12 & 4) ? "failed" : "good");
 
 
                 tp->nway = 0;
@@ -385,7 +386,7 @@ void pnic2_lnk_change(struct net_device *dev, int csr5)
 
 
 	if (tulip_debug > 1)
-		printk(KERN_INFO"%s: PNIC2 Link Change Default?\n",dev->name);
+		dev_info(&dev->dev, "PNIC2 Link Change Default?\n");
 
         /* if all else fails default to trying 10baseT-HD */
 	dev->if_port = 0;
-- 
1.6.6.rc0.57.gad7a

