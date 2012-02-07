From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] ixgb: Remove unnecessary defines, use pr_debug
Date: Tue, 07 Feb 2012 12:17:17 -0800
Message-ID: <1328645837.15787.3.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37242 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756458Ab2BGURT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 15:17:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current logging styles.

Remove unnecessary _DEBUG_DRIVER_ and PFX, use pr_debug.
Coalesce format.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb.h      |   12 ------------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c |    4 ++--
 2 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb.h b/drivers/net/ethernet/intel/ixgb/ixgb.h
index cb23448..4d2ae97 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb.h
@@ -75,18 +75,6 @@ struct ixgb_adapter;
 #include "ixgb_ee.h"
 #include "ixgb_ids.h"
 
-#define PFX "ixgb: "
-
-#ifdef _DEBUG_DRIVER_
-#define IXGB_DBG(fmt, args...) printk(KERN_DEBUG PFX fmt, ##args)
-#else
-#define IXGB_DBG(fmt, args...)				\
-do {							\
-	if (0)						\
-		printk(KERN_DEBUG PFX fmt, ##args);	\
-} while (0)
-#endif
-
 /* TX/RX descriptor defines */
 #define DEFAULT_TXD      256
 #define MAX_TXD         4096
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 0024788..82aaa79 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -2068,8 +2068,8 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 
 			/* All receives must fit into a single buffer */
 
-			IXGB_DBG("Receive packet consumed multiple buffers "
-					 "length<%x>\n", length);
+			pr_debug("Receive packet consumed multiple buffers length<%x>\n",
+				 length);
 
 			dev_kfree_skb_irq(skb);
 			goto rxdesc_done;
