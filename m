From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netdev: smc91x: drop Blackfin cruft
Date: Mon, 14 Sep 2009 14:03:42 -0400
Message-ID: <1252951422-11543-1-git-send-email-vapier@gentoo.org>
Cc: linux-kernel@vger.kernel.org,
	Michael Hennerich <michael.hennerich@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756519AbZINSDr@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Hennerich <michael.hennerich@analog.com>

Now that all Blackfin boards are using the board resources, we don't need
to keep the arch/board specific crap in the driver header.

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/smc91x.h |   28 ----------------------------
 1 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 57a159f..9c8c6ed 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -83,34 +83,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 	}
 }
 
-#elif defined(CONFIG_BLACKFIN)
-
-#define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
-#define RPC_LSA_DEFAULT		RPC_LED_100_10
-#define RPC_LSB_DEFAULT		RPC_LED_TX_RX
-
-#define SMC_CAN_USE_8BIT	0
-#define SMC_CAN_USE_16BIT	1
-# if defined(CONFIG_BF561)
-#define SMC_CAN_USE_32BIT	1
-# else
-#define SMC_CAN_USE_32BIT	0
-# endif
-#define SMC_IO_SHIFT		0
-#define SMC_NOWAIT      	1
-#define SMC_USE_BFIN_DMA	0
-
-#define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_outw(v, a, r)	writew(v, (a) + (r))
-#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-# if SMC_CAN_USE_32BIT
-#define SMC_inl(a, r)		readl((a) + (r))
-#define SMC_outl(v, a, r)	writel(v, (a) + (r))
-#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
-#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
-# endif
-
 #elif defined(CONFIG_REDWOOD_5) || defined(CONFIG_REDWOOD_6)
 
 /* We can only do 16-bit reads and writes in the static memory space. */
-- 
1.6.4.2
