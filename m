From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] ixgbe: Fix memory leak in ixgbe when receiving traffic on DDP enabled rings
Date: Wed, 20 Jun 2012 01:44:42 -0700
Message-ID: <1340181882-16333-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38319 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365Ab2FTIop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:44:45 -0400
In-Reply-To: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch fixes a memory leak that was introduced in the 3.4 kernel.  The
leak occurred when FCoE was enabled and traffic was passed over the FCoE
rings reserved for FCoE.  The memory leak was due to us not populating the
compound page information on the order 1 pages needed for FCoE.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 17ad6a3..cbb05d6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1148,7 +1148,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	/* alloc new page for storage */
 	if (likely(!page)) {
-		page = alloc_pages(GFP_ATOMIC | __GFP_COLD,
+		page = alloc_pages(GFP_ATOMIC | __GFP_COLD | __GFP_COMP,
 				   ixgbe_rx_pg_order(rx_ring));
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_rx_page_failed++;
-- 
1.7.10.2
