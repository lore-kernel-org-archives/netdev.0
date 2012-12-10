From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 03/10] net: smc91x: use io{read,write}*_rep accessors instead of string functions
Date: Mon, 10 Dec 2012 19:12:35 +0000
Message-ID: <1355166762-15133-4-git-send-email-will.deacon@arm.com>
References: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
Cc: linux-arch@vger.kernel.org, benh@kernel.crashing.org,
	arnd@arndb.de, james.hogan@imgtec.com,
	Will Deacon <will.deacon@arm.com>,
	Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The {read,write}s{b,w,l} operations are not defined by all architectures
and are being removed from the asm-generic/io.h interface.

This patch replaces the usage of these string functions in the default
SMC accessors with io{read,write}{8,16,32}_rep calls instead, which are
defined for all architectures.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
Cc: Nicolas Pitre <nico@fluxnic.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 drivers/net/ethernet/smsc/smc91x.h | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 5f53fbb..370e13d 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -286,16 +286,16 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
 
 #define SMC_IO_SHIFT		(lp->io_shift)
 
-#define SMC_inb(a, r)		readb((a) + (r))
-#define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_inl(a, r)		readl((a) + (r))
-#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
-#define SMC_outw(v, a, r)	writew(v, (a) + (r))
-#define SMC_outl(v, a, r)	writel(v, (a) + (r))
-#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
-#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
+#define SMC_inb(a, r)		ioread8((a) + (r))
+#define SMC_inw(a, r)		ioread16((a) + (r))
+#define SMC_inl(a, r)		ioread32((a) + (r))
+#define SMC_outb(v, a, r)	iowrite8(v, (a) + (r))
+#define SMC_outw(v, a, r)	iowrite16(v, (a) + (r))
+#define SMC_outl(v, a, r)	iowrite32(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	ioread16_rep((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	iowrite16_rep((a) + (r), p, l)
+#define SMC_insl(a, r, p, l)	ioread32_rep((a) + (r), p, l)
+#define SMC_outsl(a, r, p, l)	iowrite32_rep((a) + (r), p, l)
 
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
 #define RPC_LSB_DEFAULT		RPC_LED_TX_RX
-- 
1.8.0
