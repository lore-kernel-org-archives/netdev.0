From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH 3/4] 8390 cleanup - etherh iomem annotations
Date: Tue, 10 Oct 2006 00:19:36 +0100
Message-ID: <E1GX4PI-0005Mj-CO@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53226 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1751924AbWJIXTh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 19:19:37 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/arm/etherh.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
index 747a71f..f3faa4f 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/arm/etherh.c
@@ -54,10 +54,10 @@ #include <asm/io.h>
 
 #define EI_SHIFT(x)	(ei_local->reg_offset[x])
 
-#define ei_inb(_p)	 readb(_p)
-#define ei_outb(_v,_p)	 writeb(_v,_p)
-#define ei_inb_p(_p)	 readb(_p)
-#define ei_outb_p(_v,_p) writeb(_v,_p)
+#define ei_inb(_p)	 readb((void __iomem *)_p)
+#define ei_outb(_v,_p)	 writeb(_v,(void __iomem *)_p)
+#define ei_inb_p(_p)	 readb((void __iomem *)_p)
+#define ei_outb_p(_v,_p) writeb(_v,(void __iomem *)_p)
 
 #define NET_DEBUG  0
 #define DEBUG_INIT 2
@@ -184,7 +184,7 @@ etherh_setif(struct net_device *dev)
 	switch (etherh_priv(dev)->id) {
 	case PROD_I3_ETHERLAN600:
 	case PROD_I3_ETHERLAN600A:
-		addr = (void *)dev->base_addr + EN0_RCNTHI;
+		addr = (void __iomem *)dev->base_addr + EN0_RCNTHI;
 
 		switch (dev->if_port) {
 		case IF_PORT_10BASE2:
@@ -225,7 +225,7 @@ etherh_getifstat(struct net_device *dev)
 	switch (etherh_priv(dev)->id) {
 	case PROD_I3_ETHERLAN600:
 	case PROD_I3_ETHERLAN600A:
-		addr = (void *)dev->base_addr + EN0_RCNTHI;
+		addr = (void __iomem *)dev->base_addr + EN0_RCNTHI;
 		switch (dev->if_port) {
 		case IF_PORT_10BASE2:
 			stat = 1;
@@ -288,7 +288,7 @@ static void
 etherh_reset(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
-	void __iomem *addr = (void *)dev->base_addr;
+	void __iomem *addr = (void __iomem *)dev->base_addr;
 
 	writeb(E8390_NODMA+E8390_PAGE0+E8390_STOP, addr);
 
@@ -334,7 +334,7 @@ etherh_block_output (struct net_device *
 
 	ei_local->dmaing = 1;
 
-	addr = (void *)dev->base_addr;
+	addr = (void __iomem *)dev->base_addr;
 	dma_base = etherh_priv(dev)->dma_base;
 
 	count = (count + 1) & ~1;
@@ -394,7 +394,7 @@ etherh_block_input (struct net_device *d
 
 	ei_local->dmaing = 1;
 
-	addr = (void *)dev->base_addr;
+	addr = (void __iomem *)dev->base_addr;
 	dma_base = etherh_priv(dev)->dma_base;
 
 	buf = skb->data;
@@ -434,7 +434,7 @@ etherh_get_header (struct net_device *de
 
 	ei_local->dmaing = 1;
 
-	addr = (void *)dev->base_addr;
+	addr = (void __iomem *)dev->base_addr;
 	dma_base = etherh_priv(dev)->dma_base;
 
 	writeb (E8390_NODMA | E8390_PAGE0 | E8390_START, addr + E8390_CMD);
-- 
1.4.2.GIT

