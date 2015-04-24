From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 13/21] ARCNET: com90xx: fix ioaddr prefixes
Date: Fri, 24 Apr 2015 19:20:47 +0200
Message-ID: <1429896055-31680-14-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the use of the variable ioaddr in the macros
and uses it directly in the calling functions. This improves
the readability of the code and changes the macros to be used as
offsets.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com90xx.c | 52 ++++++++++++++++++++++----------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 2b99a04..d8a9fe5 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -80,14 +80,14 @@ static int numcards;
 #define MIRROR_SIZE (BUFFER_SIZE*4)
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK (ioaddr+0)	/* writable */
-#define _STATUS  (ioaddr+0)	/* readable */
-#define _COMMAND (ioaddr+1)	/* writable, returns random vals on read (?) */
-#define _CONFIG  (ioaddr+2)	/* Configuration register */
-#define _RESET   (ioaddr+8)	/* software reset (on read) */
-#define _MEMDATA (ioaddr+12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI (ioaddr+15)	/* Control registers for said */
-#define _ADDR_LO (ioaddr+14)
+#define _INTMASK	0	/* writable */
+#define _STATUS		0	/* readable */
+#define _COMMAND	1	/* writable, returns random vals on read (?) */
+#define _CONFIG		2	/* Configuration register */
+#define _RESET		8	/* software reset (on read) */
+#define _MEMDATA	12	/* Data port for IO-mapped memory */
+#define _ADDR_HI	15	/* Control registers for said */
+#define _ADDR_LO	14
 
 static int com90xx_skip_probe __initdata = 0;
 
@@ -166,7 +166,7 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		if (inb(_STATUS) == 0xFF) {
+		if (inb(ioaddr + _STATUS) == 0xFF) {
 			BUGMSG2(D_INIT_REASONS, "(empty)\n");
 			BUGMSG2(D_INIT_REASONS, "S1: ");
 			BUGLVL(D_INIT_REASONS) numprint = 0;
@@ -174,7 +174,7 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		inb(_RESET);	/* begin resetting card */
+		inb(ioaddr + _RESET);	/* begin resetting card */
 
 		BUGMSG2(D_INIT_REASONS, "\n");
 		BUGMSG2(D_INIT_REASONS, "S1: ");
@@ -308,7 +308,7 @@ static void __init com90xx_probe(void)
 		BUGMSG2(D_INIT, "%Xh ", *port);
 
 		ioaddr = *port;
-		status = inb(_STATUS);
+		status = inb(ioaddr + _STATUS);
 
 		if ((status & 0x9D)
 		    != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
@@ -319,8 +319,8 @@ static void __init com90xx_probe(void)
 			*port-- = ports[--numports];
 			continue;
 		}
-		outb(CFLAGScmd | RESETclear | CONFIGclear, _COMMAND);
-		status = inb(_STATUS);
+		outb(CFLAGScmd | RESETclear | CONFIGclear, ioaddr + _COMMAND);
+		status = inb(ioaddr + _STATUS);
 		if (status & RESETflag) {
 			BUGMSG2(D_INIT_REASONS, " (eternal reset, status=%Xh)\n",
 				status);
@@ -339,9 +339,9 @@ static void __init com90xx_probe(void)
 			 * we tell it to start receiving.
 			 */
 			airqmask = probe_irq_on();
-			outb(NORXflag, _INTMASK);
+			outb(NORXflag, ioaddr + _INTMASK);
 			udelay(1);
-			outb(0, _INTMASK);
+			outb(0, ioaddr + _INTMASK);
 			airq = probe_irq_off(airqmask);
 
 			if (airq <= 0) {
@@ -367,14 +367,14 @@ static void __init com90xx_probe(void)
 		 */
 #ifdef FAST_PROBE
 		if (numports > 1 || numshmems > 1) {
-			inb(_RESET);
+			inb(ioaddr + _RESET);
 			mdelay(RESETtime);
 		} else {
 			/* just one shmem and port, assume they match */
 			writeb(TESTvalue, iomem[0]);
 		}
 #else
-		inb(_RESET);
+		inb(ioaddr + _RESET);
 		mdelay(RESETtime);
 #endif
 
@@ -548,7 +548,7 @@ static void com90xx_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
 
-	outb(cmd, _COMMAND);
+	outb(cmd, ioaddr + _COMMAND);
 }
 
 
@@ -556,7 +556,7 @@ static int com90xx_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 
-	return inb(_STATUS);
+	return inb(ioaddr + _STATUS);
 }
 
 
@@ -564,7 +564,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
 
-	outb(mask, _INTMASK);
+	outb(mask, ioaddr + _INTMASK);
 }
 
 
@@ -581,18 +581,18 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
-	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", inb(_STATUS));
+	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", inb(ioaddr + _STATUS));
 
 	if (really_reset) {
 		/* reset the card */
-		inb(_RESET);
+		inb(ioaddr + _RESET);
 		mdelay(RESETtime);
 	}
-	outb(CFLAGScmd | RESETclear, _COMMAND);	/* clear flags & end reset */
-	outb(CFLAGScmd | CONFIGclear, _COMMAND);
+	outb(CFLAGScmd | RESETclear, ioaddr + _COMMAND);	/* clear flags & end reset */
+	outb(CFLAGScmd | CONFIGclear, ioaddr + _COMMAND);
 
 	/* don't do this until we verify that it doesn't hurt older cards! */
-	/* outb(inb(_CONFIG) | ENABLE16flag, _CONFIG); */
+	/* outb(inb(ioaddr + _CONFIG) | ENABLE16flag, ioaddr + _CONFIG); */
 
 	/* verify that the ARCnet signature byte is present */
 	if (readb(lp->mem_start) != TESTvalue) {
@@ -601,7 +601,7 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
-	outb(CONFIGcmd | EXTconf, _COMMAND);
+	outb(CONFIGcmd | EXTconf, ioaddr + _COMMAND);
 
 	/* clean out all the memory to make debugging make more sense :) */
 	BUGLVL(D_DURING)
-- 
2.1.4
