From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 11/21] ARCNET: rimi: fix ioaddr prefixes
Date: Fri, 24 Apr 2015 19:20:45 +0200
Message-ID: <1429896055-31680-12-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44288 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031543AbbDXRWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:24 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the use of the variable ioaddr in the macros
and uses it directly in the calling functions. This improves
the readability of the code and changes the macros to be used as
offsets.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rimi.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index c920b86..6e28a51 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -60,14 +60,14 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define MIRROR_SIZE (BUFFER_SIZE*4)
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK (ioaddr+0)	/* writable */
-#define _STATUS  (ioaddr+0)	/* readable */
-#define _COMMAND (ioaddr+1)	/* writable, returns random vals on read (?) */
-#define _RESET  (ioaddr+8)	/* software reset (on read) */
-#define _MEMDATA  (ioaddr+12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI  (ioaddr+15)	/* Control registers for said */
-#define _ADDR_LO  (ioaddr+14)
-#define _CONFIG  (ioaddr+2)	/* Configuration register */
+#define _INTMASK	0	/* writable */
+#define _STATUS		0	/* readable */
+#define _COMMAND	1	/* writable, returns random vals on read (?) */
+#define _RESET		8	/* software reset (on read) */
+#define _MEMDATA	12	/* Data port for IO-mapped memory */
+#define _ADDR_HI	15	/* Control registers for said */
+#define _ADDR_LO	14
+#define _CONFIG		2	/* Configuration register */
 
 /*
  * We cannot probe for a RIM I card; one reason is I don't know how to reset
@@ -253,17 +253,17 @@ static int arcrimi_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, readb(_STATUS));
+	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, readb(ioaddr + _STATUS));
 
 	if (really_reset) {
 		writeb(TESTvalue, ioaddr - 0x800);	/* fake reset */
 		return 0;
 	}
-	writeb(CFLAGScmd | RESETclear, _COMMAND);	/* clear flags & end reset */
-	writeb(CFLAGScmd | CONFIGclear, _COMMAND);
+	writeb(CFLAGScmd | RESETclear, ioaddr + _COMMAND);	/* clear flags & end reset */
+	writeb(CFLAGScmd | CONFIGclear, ioaddr + _COMMAND);
 
 	/* enable extended (512-byte) packets */
-	writeb(CONFIGcmd | EXTconf, _COMMAND);
+	writeb(CONFIGcmd | EXTconf, ioaddr + _COMMAND);
 
 	/* done!  return success. */
 	return 0;
@@ -274,7 +274,7 @@ static void arcrimi_setmask(struct net_device *dev, int mask)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	writeb(mask, _INTMASK);
+	writeb(mask, ioaddr + _INTMASK);
 }
 
 static int arcrimi_status(struct net_device *dev)
@@ -282,7 +282,7 @@ static int arcrimi_status(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	return readb(_STATUS);
+	return readb(ioaddr + _STATUS);
 }
 
 static void arcrimi_command(struct net_device *dev, int cmd)
@@ -290,7 +290,7 @@ static void arcrimi_command(struct net_device *dev, int cmd)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	writeb(cmd, _COMMAND);
+	writeb(cmd, ioaddr + _COMMAND);
 }
 
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
-- 
2.1.4
