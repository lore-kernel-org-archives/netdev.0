From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/2] sunbmac: use standard #defines from mii.h.
Date: Thu, 25 Aug 2011 11:22:36 +0200
Message-ID: <20110825092236.GB21835@electric-eye.fr.zoreil.com>
References: <20110825092019.GA21777@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37326 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320Ab1HYJkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 05:40:33 -0400
Content-Disposition: inline
In-Reply-To: <20110825092019.GA21777@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/sun/sunbmac.c |   31 ++++++++++++++++---------------
 drivers/net/ethernet/sun/sunbmac.h |   17 -----------------
 2 files changed, 16 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index c94f5ef..0d8cfd9 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -17,6 +17,7 @@
 #include <linux/crc32.h>
 #include <linux/errno.h>
 #include <linux/ethtool.h>
+#include <linux/mii.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -500,13 +501,13 @@ static int try_next_permutation(struct bigmac *bp, void __iomem *tregs)
 
 		/* Reset the PHY. */
 		bp->sw_bmcr	= (BMCR_ISOLATE | BMCR_PDOWN | BMCR_LOOPBACK);
-		bigmac_tcvr_write(bp, tregs, BIGMAC_BMCR, bp->sw_bmcr);
+		bigmac_tcvr_write(bp, tregs, MII_BMCR, bp->sw_bmcr);
 		bp->sw_bmcr	= (BMCR_RESET);
-		bigmac_tcvr_write(bp, tregs, BIGMAC_BMCR, bp->sw_bmcr);
+		bigmac_tcvr_write(bp, tregs, MII_BMCR, bp->sw_bmcr);
 
 		timeout = 64;
 		while (--timeout) {
-			bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, BIGMAC_BMCR);
+			bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, MII_BMCR);
 			if ((bp->sw_bmcr & BMCR_RESET) == 0)
 				break;
 			udelay(20);
@@ -514,11 +515,11 @@ static int try_next_permutation(struct bigmac *bp, void __iomem *tregs)
 		if (timeout == 0)
 			printk(KERN_ERR "%s: PHY reset failed.\n", bp->dev->name);
 
-		bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, BIGMAC_BMCR);
+		bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, MII_BMCR);
 
 		/* Now we try 10baseT. */
 		bp->sw_bmcr &= ~(BMCR_SPEED100);
-		bigmac_tcvr_write(bp, tregs, BIGMAC_BMCR, bp->sw_bmcr);
+		bigmac_tcvr_write(bp, tregs, MII_BMCR, bp->sw_bmcr);
 		return 0;
 	}
 
@@ -534,8 +535,8 @@ static void bigmac_timer(unsigned long data)
 
 	bp->timer_ticks++;
 	if (bp->timer_state == ltrywait) {
-		bp->sw_bmsr = bigmac_tcvr_read(bp, tregs, BIGMAC_BMSR);
-		bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, BIGMAC_BMCR);
+		bp->sw_bmsr = bigmac_tcvr_read(bp, tregs, MII_BMSR);
+		bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, MII_BMCR);
 		if (bp->sw_bmsr & BMSR_LSTATUS) {
 			printk(KERN_INFO "%s: Link is now up at %s.\n",
 			       bp->dev->name,
@@ -588,18 +589,18 @@ static void bigmac_begin_auto_negotiation(struct bigmac *bp)
 	int timeout;
 
 	/* Grab new software copies of PHY registers. */
-	bp->sw_bmsr	= bigmac_tcvr_read(bp, tregs, BIGMAC_BMSR);
-	bp->sw_bmcr	= bigmac_tcvr_read(bp, tregs, BIGMAC_BMCR);
+	bp->sw_bmsr	= bigmac_tcvr_read(bp, tregs, MII_BMSR);
+	bp->sw_bmcr	= bigmac_tcvr_read(bp, tregs, MII_BMCR);
 
 	/* Reset the PHY. */
 	bp->sw_bmcr	= (BMCR_ISOLATE | BMCR_PDOWN | BMCR_LOOPBACK);
-	bigmac_tcvr_write(bp, tregs, BIGMAC_BMCR, bp->sw_bmcr);
+	bigmac_tcvr_write(bp, tregs, MII_BMCR, bp->sw_bmcr);
 	bp->sw_bmcr	= (BMCR_RESET);
-	bigmac_tcvr_write(bp, tregs, BIGMAC_BMCR, bp->sw_bmcr);
+	bigmac_tcvr_write(bp, tregs, MII_BMCR, bp->sw_bmcr);
 
 	timeout = 64;
 	while (--timeout) {
-		bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, BIGMAC_BMCR);
+		bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, MII_BMCR);
 		if ((bp->sw_bmcr & BMCR_RESET) == 0)
 			break;
 		udelay(20);
@@ -607,11 +608,11 @@ static void bigmac_begin_auto_negotiation(struct bigmac *bp)
 	if (timeout == 0)
 		printk(KERN_ERR "%s: PHY reset failed.\n", bp->dev->name);
 
-	bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, BIGMAC_BMCR);
+	bp->sw_bmcr = bigmac_tcvr_read(bp, tregs, MII_BMCR);
 
 	/* First we try 100baseT. */
 	bp->sw_bmcr |= BMCR_SPEED100;
-	bigmac_tcvr_write(bp, tregs, BIGMAC_BMCR, bp->sw_bmcr);
+	bigmac_tcvr_write(bp, tregs, MII_BMCR, bp->sw_bmcr);
 
 	bp->timer_state = ltrywait;
 	bp->timer_ticks = 0;
@@ -1054,7 +1055,7 @@ static u32 bigmac_get_link(struct net_device *dev)
 	struct bigmac *bp = netdev_priv(dev);
 
 	spin_lock_irq(&bp->lock);
-	bp->sw_bmsr = bigmac_tcvr_read(bp, bp->tregs, BIGMAC_BMSR);
+	bp->sw_bmsr = bigmac_tcvr_read(bp, bp->tregs, MII_BMSR);
 	spin_unlock_irq(&bp->lock);
 
 	return (bp->sw_bmsr & BMSR_LSTATUS);
diff --git a/drivers/net/ethernet/sun/sunbmac.h b/drivers/net/ethernet/sun/sunbmac.h
index 4943e97..06dd217 100644
--- a/drivers/net/ethernet/sun/sunbmac.h
+++ b/drivers/net/ethernet/sun/sunbmac.h
@@ -223,23 +223,6 @@
 #define BIGMAC_PHY_EXTERNAL   0 /* External transceiver */
 #define BIGMAC_PHY_INTERNAL   1 /* Internal transceiver */
 
-/* PHY registers */
-#define BIGMAC_BMCR           0x00 /* Basic mode control register	*/
-#define BIGMAC_BMSR           0x01 /* Basic mode status register	*/
-
-/* BMCR bits */
-#define BMCR_ISOLATE            0x0400  /* Disconnect DP83840 from MII */
-#define BMCR_PDOWN              0x0800  /* Powerdown the DP83840       */
-#define BMCR_ANENABLE           0x1000  /* Enable auto negotiation     */
-#define BMCR_SPEED100           0x2000  /* Select 100Mbps              */
-#define BMCR_LOOPBACK           0x4000  /* TXD loopback bits           */
-#define BMCR_RESET              0x8000  /* Reset the DP83840           */
-
-/* BMSR bits */
-#define BMSR_ERCAP              0x0001  /* Ext-reg capability          */
-#define BMSR_JCD                0x0002  /* Jabber detected             */
-#define BMSR_LSTATUS            0x0004  /* Link status                 */
-
 /* Ring descriptors and such, same as Quad Ethernet. */
 struct be_rxd {
 	u32 rx_flags;
-- 
1.7.4.4
