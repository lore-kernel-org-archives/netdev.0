From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 04/10] net: smc911x: use io{read,write}*_rep accessors
Date: Mon, 10 Dec 2012 19:12:36 +0000
Message-ID: <1355166762-15133-5-git-send-email-will.deacon@arm.com>
References: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
Cc: linux-arch@vger.kernel.org, benh@kernel.crashing.org,
	arnd@arndb.de, james.hogan@imgtec.com,
	Matthew Leach <matthew@mattleach.net>, netdev@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Leach <matthew@mattleach.net>

The {read,write}s{b,w,l} operations are not defined by all
architectures and are being removed from the asm-generic/io.h
interface.

This patch replaces the usage of these string functions in the smc911x
accessors with io{read,write}{8,16,32}_rep calls instead.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Matthew Leach <matthew@mattleach.net>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 drivers/net/ethernet/smsc/smc911x.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
index 3269292..d51261b 100644
--- a/drivers/net/ethernet/smsc/smc911x.h
+++ b/drivers/net/ethernet/smsc/smc911x.h
@@ -159,12 +159,12 @@ static inline void SMC_insl(struct smc911x_local *lp, int reg,
 	void __iomem *ioaddr = lp->base + reg;
 
 	if (lp->cfg.flags & SMC911X_USE_32BIT) {
-		readsl(ioaddr, addr, count);
+		ioread32_rep(ioaddr, addr, count);
 		return;
 	}
 
 	if (lp->cfg.flags & SMC911X_USE_16BIT) {
-		readsw(ioaddr, addr, count * 2);
+		ioread16_rep(ioaddr, addr, count * 2);
 		return;
 	}
 
@@ -177,12 +177,12 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 	void __iomem *ioaddr = lp->base + reg;
 
 	if (lp->cfg.flags & SMC911X_USE_32BIT) {
-		writesl(ioaddr, addr, count);
+		iowrite32_rep(ioaddr, addr, count);
 		return;
 	}
 
 	if (lp->cfg.flags & SMC911X_USE_16BIT) {
-		writesw(ioaddr, addr, count * 2);
+		iowrite16_rep(ioaddr, addr, count * 2);
 		return;
 	}
 
@@ -196,14 +196,14 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 		 writew(v & 0xFFFF, (lp)->base + (r));	 \
 		 writew(v >> 16, (lp)->base + (r) + 2); \
 	 } while (0)
-#define SMC_insl(lp, r, p, l)	 readsw((short*)((lp)->base + (r)), p, l*2)
-#define SMC_outsl(lp, r, p, l)	 writesw((short*)((lp)->base + (r)), p, l*2)
+#define SMC_insl(lp, r, p, l)	 ioread16_rep((short*)((lp)->base + (r)), p, l*2)
+#define SMC_outsl(lp, r, p, l)	 iowrite16_rep((short*)((lp)->base + (r)), p, l*2)
 
 #elif	SMC_USE_32BIT
 #define SMC_inl(lp, r)		 readl((lp)->base + (r))
 #define SMC_outl(v, lp, r)	 writel(v, (lp)->base + (r))
-#define SMC_insl(lp, r, p, l)	 readsl((int*)((lp)->base + (r)), p, l)
-#define SMC_outsl(lp, r, p, l)	 writesl((int*)((lp)->base + (r)), p, l)
+#define SMC_insl(lp, r, p, l)	 ioread32_rep((int*)((lp)->base + (r)), p, l)
+#define SMC_outsl(lp, r, p, l)	 iowrite32_rep((int*)((lp)->base + (r)), p, l)
 
 #endif /* SMC_USE_16BIT */
 #endif /* SMC_DYNAMIC_BUS_CONFIG */
-- 
1.8.0
