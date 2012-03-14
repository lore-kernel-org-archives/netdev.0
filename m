From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] ixgb: Remove unnecessary defines, use pr_debug
Date: Wed, 14 Mar 2012 00:55:20 -0700
Message-ID: <1331711726-9439-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47737 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758476Ab2CNHza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 03:55:30 -0400
In-Reply-To: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use the current logging styles.

Remove unnecessary _DEBUG_DRIVER_ and PFX, use pr_debug.
Coalesce format.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by:  Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
-- 
1.7.7.6
