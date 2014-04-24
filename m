From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] igb: Change memcpy to struct assignment
Date: Thu, 24 Apr 2014 03:31:00 -0700
Message-ID: <1398335460-4283-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26391 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755972AbaDXKbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 06:31:11 -0400
In-Reply-To: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes issue found by updated coccicheck.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bb13c5b..ffaae14 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6497,7 +6497,7 @@ static void igb_reuse_rx_page(struct igb_ring *rx_ring,
 	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
 
 	/* transfer page from old buffer to new buffer */
-	memcpy(new_buff, old_buff, sizeof(struct igb_rx_buffer));
+	*new_buff = *old_buff;
 
 	/* sync the buffer for use by the device */
 	dma_sync_single_range_for_device(rx_ring->dev, old_buff->dma,
-- 
1.9.0
