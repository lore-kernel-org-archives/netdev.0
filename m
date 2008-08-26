From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/5] igb: remove unneeded cleaned variable in clean_tx_irq path
Date: Tue, 26 Aug 2008 04:25:08 -0700
Message-ID: <20080826112508.15627.3410.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37230 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbYHZLZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:25:08 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099147rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:25:08 -0700 (PDT)
In-Reply-To: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The cleaned variable can be replaced by the count of packets cleaned during
the tx interrupt routine so it can be removed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 40a205e..8d47882 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3617,16 +3617,14 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 	unsigned int i;
 	u32 head, oldhead;
 	unsigned int count = 0;
-	bool cleaned = false;
-	bool retval = true;
 	unsigned int total_bytes = 0, total_packets = 0;
+	bool retval = true;
 
 	rmb();
 	head = get_head(tx_ring);
 	i = tx_ring->next_to_clean;
 	while (1) {
 		while (i != head) {
-			cleaned = true;
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			skb = buffer_info->skb;
@@ -3643,7 +3641,6 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 			}
 
 			igb_unmap_and_free_tx_resource(adapter, buffer_info);
-			tx_desc->upper.data = 0;
 
 			i++;
 			if (i == tx_ring->count)
@@ -3665,7 +3662,7 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 done_cleaning:
 	tx_ring->next_to_clean = i;
 
-	if (unlikely(cleaned &&
+	if (unlikely(count &&
 		     netif_carrier_ok(netdev) &&
 		     IGB_DESC_UNUSED(tx_ring) >= IGB_TX_QUEUE_WAKE)) {
 		/* Make sure that anybody stopping the queue after this

