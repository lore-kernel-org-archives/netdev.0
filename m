From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/13] tulip/timer.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:26 -0800
Message-ID: <5d0c96dbfcbfb67590f24151732927939a0bd664.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1595 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129Ab0A2G7c (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/tulip/timer.c |   52 +++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/drivers/net/tulip/timer.c b/drivers/net/tulip/timer.c
index a0e0842..36c2725 100644
--- a/drivers/net/tulip/timer.c
+++ b/drivers/net/tulip/timer.c
@@ -28,11 +28,11 @@ void tulip_media_task(struct work_struct *work)
 	unsigned long flags;
 
 	if (tulip_debug > 2) {
-		printk(KERN_DEBUG "%s: Media selection tick, %s, status %8.8x mode"
-			   " %8.8x SIA %8.8x %8.8x %8.8x %8.8x.\n",
-			   dev->name, medianame[dev->if_port], ioread32(ioaddr + CSR5),
-			   ioread32(ioaddr + CSR6), csr12, ioread32(ioaddr + CSR13),
-			   ioread32(ioaddr + CSR14), ioread32(ioaddr + CSR15));
+		printk(KERN_DEBUG "%s: Media selection tick, %s, status %08x mode %08x SIA %08x %08x %08x %08x\n",
+		       dev->name, medianame[dev->if_port],
+		       ioread32(ioaddr + CSR5), ioread32(ioaddr + CSR6),
+		       csr12, ioread32(ioaddr + CSR13),
+		       ioread32(ioaddr + CSR14), ioread32(ioaddr + CSR15));
 	}
 	switch (tp->chip_id) {
 	case DC21140:
@@ -48,9 +48,9 @@ void tulip_media_task(struct work_struct *work)
 			   Assume this a generic MII or SYM transceiver. */
 			next_tick = 60*HZ;
 			if (tulip_debug > 2)
-				printk(KERN_DEBUG "%s: network media monitor CSR6 %8.8x "
-					   "CSR12 0x%2.2x.\n",
-					   dev->name, ioread32(ioaddr + CSR6), csr12 & 0xff);
+				printk(KERN_DEBUG "%s: network media monitor CSR6 %08x CSR12 0x%02x\n",
+				       dev->name,
+				       ioread32(ioaddr + CSR6), csr12 & 0xff);
 			break;
 		}
 		mleaf = &tp->mtable->mleaf[tp->cur_index];
@@ -62,9 +62,8 @@ void tulip_media_task(struct work_struct *work)
 			s8 bitnum = p[offset];
 			if (p[offset+1] & 0x80) {
 				if (tulip_debug > 1)
-					printk(KERN_DEBUG"%s: Transceiver monitor tick "
-						   "CSR12=%#2.2x, no media sense.\n",
-						   dev->name, csr12);
+					printk(KERN_DEBUG "%s: Transceiver monitor tick CSR12=%#02x, no media sense\n",
+					       dev->name, csr12);
 				if (mleaf->type == 4) {
 					if (mleaf->media == 3 && (csr12 & 0x02))
 						goto select_next_media;
@@ -72,16 +71,16 @@ void tulip_media_task(struct work_struct *work)
 				break;
 			}
 			if (tulip_debug > 2)
-				printk(KERN_DEBUG "%s: Transceiver monitor tick: CSR12=%#2.2x"
-					   " bit %d is %d, expecting %d.\n",
-					   dev->name, csr12, (bitnum >> 1) & 7,
-					   (csr12 & (1 << ((bitnum >> 1) & 7))) != 0,
-					   (bitnum >= 0));
+				printk(KERN_DEBUG "%s: Transceiver monitor tick: CSR12=%#02x bit %d is %d, expecting %d\n",
+				       dev->name, csr12, (bitnum >> 1) & 7,
+				       (csr12 & (1 << ((bitnum >> 1) & 7))) != 0,
+				       (bitnum >= 0));
 			/* Check that the specified bit has the proper value. */
 			if ((bitnum < 0) !=
 				((csr12 & (1 << ((bitnum >> 1) & 7))) != 0)) {
 				if (tulip_debug > 2)
-					printk(KERN_DEBUG "%s: Link beat detected for %s.\n", dev->name,
+					printk(KERN_DEBUG "%s: Link beat detected for %s\n",
+					       dev->name,
 					       medianame[mleaf->media & MEDIA_MASK]);
 				if ((p[2] & 0x61) == 0x01)	/* Bogus Znyx board. */
 					goto actually_mii;
@@ -100,9 +99,9 @@ void tulip_media_task(struct work_struct *work)
 			if (tulip_media_cap[dev->if_port] & MediaIsFD)
 				goto select_next_media; /* Skip FD entries. */
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: No link beat on media %s,"
-				       " trying transceiver type %s.\n",
-				       dev->name, medianame[mleaf->media & MEDIA_MASK],
+				printk(KERN_DEBUG "%s: No link beat on media %s, trying transceiver type %s\n",
+				       dev->name,
+				       medianame[mleaf->media & MEDIA_MASK],
 				       medianame[tp->mtable->mleaf[tp->cur_index].media]);
 			tulip_select_media(dev, 0);
 			/* Restart the transmit process. */
@@ -151,8 +150,8 @@ void mxic_timer(unsigned long data)
 	int next_tick = 60*HZ;
 
 	if (tulip_debug > 3) {
-		printk(KERN_INFO"%s: MXIC negotiation status %8.8x.\n", dev->name,
-			   ioread32(ioaddr + CSR12));
+		dev_info(&dev->dev, "MXIC negotiation status %08x\n",
+			 ioread32(ioaddr + CSR12));
 	}
 	if (next_tick) {
 		mod_timer(&tp->timer, RUN_AT(next_tick));
@@ -167,11 +166,10 @@ void comet_timer(unsigned long data)
 	int next_tick = 60*HZ;
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: Comet link status %4.4x partner capability "
-			   "%4.4x.\n",
-			   dev->name,
-			   tulip_mdio_read(dev, tp->phys[0], 1),
-			   tulip_mdio_read(dev, tp->phys[0], 5));
+		printk(KERN_DEBUG "%s: Comet link status %04x partner capability %04x\n",
+		       dev->name,
+		       tulip_mdio_read(dev, tp->phys[0], 1),
+		       tulip_mdio_read(dev, tp->phys[0], 5));
 	/* mod_timer synchronizes us with potential add_timer calls
 	 * from interrupts.
 	 */
-- 
1.6.6.rc0.57.gad7a

