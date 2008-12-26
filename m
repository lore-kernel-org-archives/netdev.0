From: David Miller <davem@davemloft.net>
Subject: [PATCH] igb: Fix build warning when DCA is disabled.
Date: Fri, 26 Dec 2008 15:14:23 -0800 (PST)
Message-ID: <20081226.151423.241809329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752164AbYLZXOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 18:14:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just pushed the following to net-next-2.6

igb: Fix build warning when DCA is disabled.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/igb/igb_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 9331e52..022794e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3379,7 +3379,6 @@ static void igb_write_itr(struct igb_ring *ring)
 static irqreturn_t igb_msix_rx(int irq, void *data)
 {
 	struct igb_ring *rx_ring = data;
-	struct igb_adapter *adapter = rx_ring->adapter;
 
 	/* Write the ITR value calculated at the end of the
 	 * previous interrupt.
@@ -3391,7 +3390,7 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 		__netif_rx_schedule(&rx_ring->napi);
 
 #ifdef CONFIG_IGB_DCA
-	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+	if (rx_ring->adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif
 		return IRQ_HANDLED;
-- 
1.5.6.5

