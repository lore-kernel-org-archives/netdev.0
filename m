From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V4 net-next 11/13] net/ena: change driver's default timeouts
Date: Thu,  9 Feb 2017 15:21:37 +0200
Message-ID: <1486646499-13682-12-git-send-email-netanel@annapurnalabs.com>
References: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com,
        evgenys@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36848 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752580AbdBINbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:31:12 -0500
Received: by mail-wm0-f43.google.com with SMTP id c85so230739141wmi.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:30:48 -0800 (PST)
In-Reply-To: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timeouts were too agressive and sometimes cause false alarms.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c    | 4 ++--
 drivers/net/ethernet/amazon/ena/ena_netdev.h | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 5518b1f..8029e7c 100644
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
index f0ddc11..efe0ea1 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -100,7 +100,7 @@
 /* Number of queues to check for missing queues per timer service */
 #define ENA_MONITORED_TX_QUEUES	4
 /* Max timeout packets before device reset */
-#define MAX_NUM_OF_TIMEOUTED_PACKETS 32
+#define MAX_NUM_OF_TIMEOUTED_PACKETS 128
 
 #define ENA_TX_RING_IDX_NEXT(idx, ring_size) (((idx) + 1) & ((ring_size) - 1))
 
@@ -116,9 +116,9 @@
 #define ENA_IO_IRQ_IDX(q)		(ENA_IO_IRQ_FIRST_IDX + (q))
 
 /* ENA device should send keep alive msg every 1 sec.
- * We wait for 3 sec just to be on the safe side.
+ * We wait for 6 sec just to be on the safe side.
  */
-#define ENA_DEVICE_KALIVE_TIMEOUT	(3 * HZ)
+#define ENA_DEVICE_KALIVE_TIMEOUT	(6 * HZ)
 
 #define ENA_MMIO_DISABLE_REG_READ	BIT(0)
 
-- 
2.7.4
