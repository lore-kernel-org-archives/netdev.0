From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ixgbe: support skb->xmit_more in
 netdev_ops->ndo_start_xmit()
Date: Mon, 25 Aug 2014 16:35:05 -0700 (PDT)
Message-ID: <20140825.163505.1969688661687017343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756746AbaHYXfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:35:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Daniel Borkmann <dborkman@redhat.com>

This implements the deferred tail pointer flush API for the ixgbe
driver. Similar version also proposed longer time ago by Alexander Duyck.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 87bd53f..ba9ceaa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6958,9 +6958,10 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 	tx_ring->next_to_use = i;
 
-	/* notify HW of packet */
-	ixgbe_write_tail(tx_ring, i);
-
+	if (!skb->xmit_more) {
+		/* notify HW of packet */
+		ixgbe_write_tail(tx_ring, i);
+	}
 	return;
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
-- 
1.7.11.7
