From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 18/18] net/ena: change driver's default timeouts and increase driver version
Date: Sun, 20 Nov 2016 10:45:47 +0200
Message-ID: <1479631547-29354-19-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver version was increased to 1.1.2

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c    | 4 ++--
 drivers/net/ethernet/amazon/ena/ena_netdev.h | 9 +++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index b2891f9..9b158f0 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -36,9 +36,9 @@
 /*****************************************************************************/
 
 /* Timeout in micro-sec */
-#define ADMIN_CMD_TIMEOUT_US (1000000)
+#define ADMIN_CMD_TIMEOUT_US (3000000)
 
-#define ENA_ASYNC_QUEUE_DEPTH 4
+#define ENA_ASYNC_QUEUE_DEPTH 16
 #define ENA_ADMIN_QUEUE_DEPTH 32
 
 #define MIN_ENA_VER (((ENA_COMMON_SPEC_VERSION_MAJOR) << \
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index c081fd3..de1e5ac 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -39,12 +39,13 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/u64_stats_sync.h>
 
 #include "ena_com.h"
 #include "ena_eth_com.h"
 
 #define DRV_MODULE_VER_MAJOR	1
-#define DRV_MODULE_VER_MINOR	0
+#define DRV_MODULE_VER_MINOR	1
 #define DRV_MODULE_VER_SUBMINOR 2
 
 #define DRV_MODULE_NAME		"ena"
@@ -100,7 +101,7 @@
 /* Number of queues to check for missing queues per timer service */
 #define ENA_MONITORED_TX_QUEUES	4
 /* Max timeout packets before device reset */
-#define MAX_NUM_OF_TIMEOUTED_PACKETS 32
+#define MAX_NUM_OF_TIMEOUTED_PACKETS 128
 
 #define ENA_TX_RING_IDX_NEXT(idx, ring_size) (((idx) + 1) & ((ring_size) - 1))
 
@@ -116,9 +117,9 @@
 #define ENA_IO_IRQ_IDX(q)		(ENA_IO_IRQ_FIRST_IDX + (q))
 
 /* ENA device should send keep alive msg every 1 sec.
- * We wait for 3 sec just to be on the safe side.
+ * We wait for 6 sec just to be on the safe side.
  */
-#define ENA_DEVICE_KALIVE_TIMEOUT	(3 * HZ)
+#define ENA_DEVICE_KALIVE_TIMEOUT	(6 * HZ)
 
 #define ENA_MMIO_DISABLE_REG_READ	BIT(0)
 
-- 
1.9.1
