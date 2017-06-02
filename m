From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] netxen: remove writeq/readq function definitions
Date: Fri,  2 Jun 2017 13:36:27 +0200
Message-ID: <20170602113627.28642-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of rewriting write/readq, use linux/io-64-nonatomic-lo-hi.h which
already have them.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index a996801d442d..66ff15d08bad 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -21,6 +21,7 @@
  *
  */
 
+#include <linux/io-64-nonatomic-lo-hi.h>
 #include <linux/slab.h>
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
@@ -44,20 +45,6 @@ static void netxen_nic_io_write_128M(struct netxen_adapter *adapter,
 		void __iomem *addr, u32 data);
 static u32 netxen_nic_io_read_128M(struct netxen_adapter *adapter,
 		void __iomem *addr);
-#ifndef readq
-static inline u64 readq(void __iomem *addr)
-{
-	return readl(addr) | (((u64) readl(addr + 4)) << 32LL);
-}
-#endif
-
-#ifndef writeq
-static inline void writeq(u64 val, void __iomem *addr)
-{
-	writel(((u32) (val)), (addr));
-	writel(((u32) (val >> 32)), (addr + 4));
-}
-#endif
 
 #define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
 	((adapter)->ahw.pci_base0 + (off))
-- 
2.13.0
