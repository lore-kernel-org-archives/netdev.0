From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 18/21] ARCNET: com20020: remove obsolete BUS_ALIGN offset factor
Date: Fri, 24 Apr 2015 19:20:52 +0200
Message-ID: <1429896055-31680-19-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44292 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031546AbbDXRWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:24 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the obsolete macro BUS_ALIGN as the kernel option
CONFIG_SA1100_CT6001 is not longer available.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020.c |  4 ++--
 include/linux/com20020.h      | 27 ++++++++++-----------------
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 27ad484..1dbc748 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -134,7 +134,7 @@ int com20020_check(struct net_device *dev)
 	/* Enable TX */
 	lp->config |= TXENcfg;
 	outb(lp->config, ioaddr + _CONFIG);
-	outb(inb(ioaddr + BUS_ALIGN * 8), ioaddr + _XREG);
+	outb(inb(ioaddr + 8), ioaddr + _XREG);
 
 	outb((CFLAGScmd | RESETclear | CONFIGclear), ioaddr + _COMMAND);
 
@@ -200,7 +200,7 @@ int com20020_found(struct net_device *dev, int shared)
 	lp->hw.close = com20020_close;
 
 	if (!dev->dev_addr[0])
-		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN*8);	/* FIXME: do this some other way! */
+		dev->dev_addr[0] = inb(ioaddr + 8);	/* FIXME: do this some other way! */
 
 	lp->config = (lp->config & ~0x03) | SUB_SETUP1;
 	outb(lp->config, ioaddr + _CONFIG);
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index f194b74..939d69d 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -34,13 +34,6 @@ extern const struct net_device_ops com20020_netdev_ops;
 /* The number of low I/O ports used by the card. */
 #define ARCNET_TOTAL_SIZE 8
 
-/* various register addresses */
-#ifdef CONFIG_SA1100_CT6001
-#define BUS_ALIGN  2  /* 8 bit device on a 16 bit bus - needs padding */
-#else
-#define BUS_ALIGN  1
-#endif
-
 #define PLX_PCI_MAX_CARDS 2
 
 struct com20020_pci_channel_map {
@@ -71,16 +64,16 @@ struct com20020_dev {
 	int index;
 };
 
-#define _INTMASK  (BUS_ALIGN*0)	/* writable */
-#define _STATUS   (BUS_ALIGN*0)	/* readable */
-#define _COMMAND  (BUS_ALIGN*1)	/* standard arcnet commands */
-#define _DIAGSTAT (BUS_ALIGN*1)	/* diagnostic status register */
-#define _ADDR_HI  (BUS_ALIGN*2)	/* control registers for IO-mapped memory */
-#define _ADDR_LO  (BUS_ALIGN*3)
-#define _MEMDATA  (BUS_ALIGN*4)	/* data port for IO-mapped memory */
-#define _SUBADR   (BUS_ALIGN*5)	/* the extended port _XREG refers to */
-#define _CONFIG   (BUS_ALIGN*6)	/* configuration register */
-#define _XREG     (BUS_ALIGN*7)	/* extra registers (indexed by _CONFIG
+#define _INTMASK  0	/* writable */
+#define _STATUS   0	/* readable */
+#define _COMMAND  1	/* standard arcnet commands */
+#define _DIAGSTAT 1	/* diagnostic status register */
+#define _ADDR_HI  2	/* control registers for IO-mapped memory */
+#define _ADDR_LO  3
+#define _MEMDATA  4	/* data port for IO-mapped memory */
+#define _SUBADR   5	/* the extended port _XREG refers to */
+#define _CONFIG   6	/* configuration register */
+#define _XREG     7	/* extra registers (indexed by _CONFIG
 					or _SUBADR) */
 
 /* in the ADDR_HI register */
-- 
2.1.4
