From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] soc: ti/knav_dma: include dmaengine header
Date: Tue,  5 Sep 2017 10:31:35 +0200
Message-ID: <20170905083146.1289546-1-arnd@arndb.de>
Cc: Dave Jiang <dave.jiang@intel.com>, netdev@vger.kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org
To: arm@kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A header file cleanup apparently caused a build regression
with one driver using the knav infrastructure:

In file included from drivers/net/ethernet/ti/netcp_core.c:30:0:
include/linux/soc/ti/knav_dma.h:129:30: error: field 'direction' has incomplete type
  enum dma_transfer_direction direction;
                              ^~~~~~~~~
drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_txpipe_open':
drivers/net/ethernet/ti/netcp_core.c:1349:21: error: 'DMA_MEM_TO_DEV' undeclared (first use in this function); did you mean 'DMA_MEMORY_MAP'?
  config.direction = DMA_MEM_TO_DEV;
                     ^~~~~~~~~~~~~~
                     DMA_MEMORY_MAP
drivers/net/ethernet/ti/netcp_core.c:1349:21: note: each undeclared identifier is reported only once for each function it appears in
drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_setup_navigator_resources':
drivers/net/ethernet/ti/netcp_core.c:1659:22: error: 'DMA_DEV_TO_MEM' undeclared (first use in this function); did you mean 'DMA_DESC_HOST'?
  config.direction  = DMA_DEV_TO_MEM;

As the header is no longer included implicitly through netdevice.h,
we should include it in the header that references the enum.

Fixes: 0dd5759dbb1c ("net: remove dmaengine.h inclusion from netdevice.h")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
If the cleanup patch hasn't been submitted for mainline yet, please
add this fixup to the net-next tree, otherwise I'll merge it through
arm-soc.
---
 include/linux/soc/ti/knav_dma.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/soc/ti/knav_dma.h b/include/linux/soc/ti/knav_dma.h
index 2b7882666ef6..66693bc4c6ad 100644
--- a/include/linux/soc/ti/knav_dma.h
+++ b/include/linux/soc/ti/knav_dma.h
@@ -17,6 +17,8 @@
 #ifndef __SOC_TI_KEYSTONE_NAVIGATOR_DMA_H__
 #define __SOC_TI_KEYSTONE_NAVIGATOR_DMA_H__
 
+#include <linux/dmaengine.h>
+
 /*
  * PKTDMA descriptor manipulation macros for host packet descriptor
  */
-- 
2.9.0
