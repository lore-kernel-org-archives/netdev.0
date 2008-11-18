From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH] netdev/smc91x: unify Blackfin code a bit and use proper read/write functions
Date: Tue, 18 Nov 2008 15:23:40 +0800
Message-ID: <1226993020-31357-1-git-send-email-cooloney@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	Mike Frysinger <vapier.adi@gmail.com>,
	Bryan Wu <cooloney@kernel.org>
To: nico@cam.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:42116 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbYKRHWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 02:22:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>

Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/smc91x.h |   45 ++++++++++++---------------------------------
 1 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index a07cc93..f6d6379 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -87,49 +87,28 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
 #define RPC_LSB_DEFAULT		RPC_LED_TX_RX
 
-# if defined (CONFIG_BFIN561_EZKIT)
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
+# if defined(CONFIG_BF561)
 #define SMC_CAN_USE_32BIT	1
-#define SMC_IO_SHIFT		0
-#define SMC_NOWAIT      	1
-#define SMC_USE_BFIN_DMA	0
-
-
-#define SMC_inw(a, r)       	readw((a) + (r))
-#define SMC_outw(v, a, r)   	writew(v, (a) + (r))
-#define SMC_inl(a, r)       	readl((a) + (r))
-#define SMC_outl(v, a, r)   	writel(v, (a) + (r))
-#define SMC_outsl(a, r, p, l)	outsl((unsigned long *)((a) + (r)), p, l)
-#define SMC_insl(a, r, p, l) 	insl ((unsigned long *)((a) + (r)), p, l)
 # else
-#define SMC_CAN_USE_8BIT	0
-#define SMC_CAN_USE_16BIT	1
 #define SMC_CAN_USE_32BIT	0
+# endif
 #define SMC_IO_SHIFT		0
 #define SMC_NOWAIT      	1
 #define SMC_USE_BFIN_DMA	0
 
-
-#define SMC_inw(a, r)       	readw((a) + (r))
-#define SMC_outw(v, a, r)   	writew(v, (a) + (r))
-#define SMC_outsw(a, r, p, l)	outsw((unsigned long *)((a) + (r)), p, l)
-#define SMC_insw(a, r, p, l) 	insw ((unsigned long *)((a) + (r)), p, l)
+#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_outw(v, a, r)	writew(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
+# if SMC_CAN_USE_32BIT
+#define SMC_inl(a, r)		readl((a) + (r))
+#define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
+#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 # endif
-/* check if the mac in reg is valid */
-#define SMC_GET_MAC_ADDR(lp, addr)				\
-	do {							\
-		unsigned int __v;				\
-		__v = SMC_inw(ioaddr, ADDR0_REG(lp));		\
-		addr[0] = __v; addr[1] = __v >> 8;		\
-		__v = SMC_inw(ioaddr, ADDR1_REG(lp));		\
-		addr[2] = __v; addr[3] = __v >> 8;		\
-		__v = SMC_inw(ioaddr, ADDR2_REG(lp));		\
-		addr[4] = __v; addr[5] = __v >> 8;		\
-		if (*(u32 *)(&addr[0]) == 0xFFFFFFFF) {		\
-			random_ether_addr(addr);		\
-		}						\
-	} while (0)
+
 #elif defined(CONFIG_REDWOOD_5) || defined(CONFIG_REDWOOD_6)
 
 /* We can only do 16-bit reads and writes in the static memory space. */
-- 
1.5.6.3
