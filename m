From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 05/10] net: dm9000: use io{read,write}*_rep accessors
Date: Mon, 10 Dec 2012 19:12:37 +0000
Message-ID: <1355166762-15133-6-git-send-email-will.deacon@arm.com>
References: <1355166762-15133-1-git-send-email-will.deacon@arm.com>
Cc: linux-arch@vger.kernel.org, benh@kernel.crashing.org,
	arnd@arndb.de, james.hogan@imgtec.com,
	Matthew Leach <matthew@mattleach.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
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

This patch replaces the usage of these string functions in the default
DM9000 accessors with io{read,write}{8,16,32}_rep calls instead. This
is required as the dm9000 driver is in use by the blackfin
architecture which uses the asm-generic io accessors.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
Cc: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Matthew Leach <matthew@mattleach.net>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 36499d5..61648a6 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -193,35 +193,35 @@ iow(board_info_t * db, int reg, int value)
 
 static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
 {
-	writesb(reg, data, count);
+	iowrite8_rep(reg, data, count);
 }
 
 static void dm9000_outblk_16bit(void __iomem *reg, void *data, int count)
 {
-	writesw(reg, data, (count+1) >> 1);
+	iowrite16_rep(reg, data, (count+1) >> 1);
 }
 
 static void dm9000_outblk_32bit(void __iomem *reg, void *data, int count)
 {
-	writesl(reg, data, (count+3) >> 2);
+	iowrite32_rep(reg, data, (count+3) >> 2);
 }
 
 /* input block from chip to memory */
 
 static void dm9000_inblk_8bit(void __iomem *reg, void *data, int count)
 {
-	readsb(reg, data, count);
+	ioread8_rep(reg, data, count);
 }
 
 
 static void dm9000_inblk_16bit(void __iomem *reg, void *data, int count)
 {
-	readsw(reg, data, (count+1) >> 1);
+	ioread16_rep(reg, data, (count+1) >> 1);
 }
 
 static void dm9000_inblk_32bit(void __iomem *reg, void *data, int count)
 {
-	readsl(reg, data, (count+3) >> 2);
+	ioread32_rep(reg, data, (count+3) >> 2);
 }
 
 /* dump block from chip to null */
-- 
1.8.0
