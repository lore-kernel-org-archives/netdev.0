From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/13] tulip/21142.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:18 -0800
Message-ID: <069e40cd1c8f458b2ff056530a5e85ef688b350e.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1580 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942Ab0A2G7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:30 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/21142.c |   76 +++++++++++++++++++++++----------------------
 1 files changed, 39 insertions(+), 37 deletions(-)

diff --git a/drivers/net/tulip/21142.c b/drivers/net/tulip/21142.c
index 9f6742f..007d8e7 100644
--- a/drivers/net/tulip/21142.c
+++ b/drivers/net/tulip/21142.c
@@ -43,8 +43,8 @@ void t21142_media_task(struct work_struct *work)
 	if ((csr14 & 0x80) && (csr12 & 0x7000) != 0x5000)
 		csr12 |= 6;
 	if (tulip_debug > 2)
-		printk(KERN_INFO"%s: 21143 negotiation status %8.8x, %s.\n",
-			   dev->name, csr12, medianame[dev->if_port]);
+		dev_info(&dev->dev, "21143 negotiation status %08x, %s\n",
+			 csr12, medianame[dev->if_port]);
 	if (tulip_media_cap[dev->if_port] & MediaIsMII) {
 		if (tulip_check_duplex(dev) < 0) {
 			netif_carrier_off(dev);
@@ -56,23 +56,26 @@ void t21142_media_task(struct work_struct *work)
 	} else if (tp->nwayset) {
 		/* Don't screw up a negotiated session! */
 		if (tulip_debug > 1)
-			printk(KERN_INFO"%s: Using NWay-set %s media, csr12 %8.8x.\n",
-				   dev->name, medianame[dev->if_port], csr12);
+			dev_info(&dev->dev,
+				 "Using NWay-set %s media, csr12 %08x\n",
+				 medianame[dev->if_port], csr12);
 	} else if (tp->medialock) {
 			;
 	} else if (dev->if_port == 3) {
 		if (csr12 & 2) {	/* No 100mbps link beat, revert to 10mbps. */
 			if (tulip_debug > 1)
-				printk(KERN_INFO"%s: No 21143 100baseTx link beat, %8.8x, "
-					   "trying NWay.\n", dev->name, csr12);
+				dev_info(&dev->dev,
+					 "No 21143 100baseTx link beat, %08x, trying NWay\n",
+					 csr12);
 			t21142_start_nway(dev);
 			next_tick = 3*HZ;
 		}
 	} else if ((csr12 & 0x7000) != 0x5000) {
 		/* Negotiation failed.  Search media types. */
 		if (tulip_debug > 1)
-			printk(KERN_INFO"%s: 21143 negotiation failed, status %8.8x.\n",
-				   dev->name, csr12);
+			dev_info(&dev->dev,
+				 "21143 negotiation failed, status %08x\n",
+				 csr12);
 		if (!(csr12 & 4)) {		/* 10mbps link beat good. */
 			new_csr6 = 0x82420000;
 			dev->if_port = 0;
@@ -90,8 +93,8 @@ void t21142_media_task(struct work_struct *work)
 			iowrite32(1, ioaddr + CSR13);
 		}
 		if (tulip_debug > 1)
-			printk(KERN_INFO"%s: Testing new 21143 media %s.\n",
-				   dev->name, medianame[dev->if_port]);
+			dev_info(&dev->dev, "Testing new 21143 media %s\n",
+				 medianame[dev->if_port]);
 		if (new_csr6 != (tp->csr6 & ~0x00D5)) {
 			tp->csr6 &= 0x00D5;
 			tp->csr6 |= new_csr6;
@@ -119,8 +122,8 @@ void t21142_start_nway(struct net_device *dev)
 	tp->nway = tp->mediasense = 1;
 	tp->nwayset = tp->lpar = 0;
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: Restarting 21143 autonegotiation, csr14=%8.8x.\n",
-			   dev->name, csr14);
+		printk(KERN_DEBUG "%s: Restarting 21143 autonegotiation, csr14=%08x\n",
+		       dev->name, csr14);
 	iowrite32(0x0001, ioaddr + CSR13);
 	udelay(100);
 	iowrite32(csr14, ioaddr + CSR14);
@@ -147,8 +150,9 @@ void t21142_lnk_change(struct net_device *dev, int csr5)
 	if ((csr14 & 0x80) && (csr12 & 0x7000) != 0x5000)
 		csr12 |= 6;
 	if (tulip_debug > 1)
-		printk(KERN_INFO"%s: 21143 link status interrupt %8.8x, CSR5 %x, "
-			   "%8.8x.\n", dev->name, csr12, csr5, csr14);
+		dev_info(&dev->dev,
+			 "21143 link status interrupt %08x, CSR5 %x, %08x\n",
+			 csr12, csr5, csr14);
 
 	/* If NWay finished and we have a negotiated partner capability. */
 	if (tp->nway  &&  !tp->nwayset  &&  (csr12 & 0x7000) == 0x5000) {
@@ -171,14 +175,15 @@ void t21142_lnk_change(struct net_device *dev, int csr5)
 
 		if (tulip_debug > 1) {
 			if (tp->nwayset)
-				printk(KERN_INFO "%s: Switching to %s based on link "
-					   "negotiation %4.4x & %4.4x = %4.4x.\n",
-					   dev->name, medianame[dev->if_port], tp->sym_advertise,
-					   tp->lpar, negotiated);
+				dev_info(&dev->dev,
+					 "Switching to %s based on link negotiation %04x & %04x = %04x\n",
+					 medianame[dev->if_port],
+					 tp->sym_advertise, tp->lpar,
+					 negotiated);
 			else
-				printk(KERN_INFO "%s: Autonegotiation failed, using %s,"
-					   " link beat status %4.4x.\n",
-					   dev->name, medianame[dev->if_port], csr12);
+				dev_info(&dev->dev,
+					 "Autonegotiation failed, using %s, link beat status %04x\n",
+					 medianame[dev->if_port], csr12);
 		}
 
 		if (tp->mtable) {
@@ -201,14 +206,14 @@ void t21142_lnk_change(struct net_device *dev, int csr5)
 #if 0							/* Restart shouldn't be needed. */
 		iowrite32(tp->csr6 | RxOn, ioaddr + CSR6);
 		if (tulip_debug > 2)
-			printk(KERN_DEBUG "%s:  Restarting Tx and Rx, CSR5 is %8.8x.\n",
-				   dev->name, ioread32(ioaddr + CSR5));
+			printk(KERN_DEBUG "%s:  Restarting Tx and Rx, CSR5 is %08x\n",
+			       dev->name, ioread32(ioaddr + CSR5));
 #endif
 		tulip_start_rxtx(tp);
 		if (tulip_debug > 2)
-			printk(KERN_DEBUG "%s:  Setting CSR6 %8.8x/%x CSR12 %8.8x.\n",
-				   dev->name, tp->csr6, ioread32(ioaddr + CSR6),
-				   ioread32(ioaddr + CSR12));
+			printk(KERN_DEBUG "%s:  Setting CSR6 %08x/%x CSR12 %08x\n",
+			       dev->name, tp->csr6, ioread32(ioaddr + CSR6),
+			       ioread32(ioaddr + CSR12));
 	} else if ((tp->nwayset  &&  (csr5 & 0x08000000) &&
 		    (dev->if_port == 3  ||  dev->if_port == 5) &&
 		    (csr12 & 2) == 2) ||
@@ -220,9 +225,9 @@ void t21142_lnk_change(struct net_device *dev, int csr5)
 		add_timer(&tp->timer);
 	} else if (dev->if_port == 3  ||  dev->if_port == 5) {
 		if (tulip_debug > 1)
-			printk(KERN_INFO"%s: 21143 %s link beat %s.\n",
-				   dev->name, medianame[dev->if_port],
-				   (csr12 & 2) ? "failed" : "good");
+			dev_info(&dev->dev, "21143 %s link beat %s\n",
+				 medianame[dev->if_port],
+				 (csr12 & 2) ? "failed" : "good");
 		if ((csr12 & 2)  &&  ! tp->medialock) {
 			del_timer_sync(&tp->timer);
 			t21142_start_nway(dev);
@@ -232,21 +237,18 @@ void t21142_lnk_change(struct net_device *dev, int csr5)
 			iowrite32(csr14 & ~0x080, ioaddr + CSR14);
 	} else if (dev->if_port == 0  ||  dev->if_port == 4) {
 		if ((csr12 & 4) == 0)
-			printk(KERN_INFO"%s: 21143 10baseT link beat good.\n",
-				   dev->name);
+			dev_info(&dev->dev, "21143 10baseT link beat good\n");
 	} else if (!(csr12 & 4)) {		/* 10mbps link beat good. */
 		if (tulip_debug)
-			printk(KERN_INFO"%s: 21143 10mbps sensed media.\n",
-				   dev->name);
+			dev_info(&dev->dev, "21143 10mbps sensed media\n");
 		dev->if_port = 0;
 	} else if (tp->nwayset) {
 		if (tulip_debug)
-			printk(KERN_INFO"%s: 21143 using NWay-set %s, csr6 %8.8x.\n",
-				   dev->name, medianame[dev->if_port], tp->csr6);
+			dev_info(&dev->dev, "21143 using NWay-set %s, csr6 %08x\n",
+				 medianame[dev->if_port], tp->csr6);
 	} else {		/* 100mbps link beat good. */
 		if (tulip_debug)
-			printk(KERN_INFO"%s: 21143 100baseTx sensed media.\n",
-				   dev->name);
+			dev_info(&dev->dev, "21143 100baseTx sensed media\n");
 		dev->if_port = 3;
 		tp->csr6 = 0x838E0000 | (tp->csr6 & 0x20ff);
 		iowrite32(0x0003FF7F, ioaddr + CSR14);
-- 
1.6.6.rc0.57.gad7a

