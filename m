From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 4/5] fm10k/igb/ixgbe: Replace __skb_alloc_page
 with netdev_alloc_page
Date: Tue, 11 Nov 2014 09:11:17 -0800
Message-ID: <20141111171117.15976.41609.stgit@ahduyck-vm-fedora20>
References: <20141111170711.15976.44062.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbaKKRLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 12:11:33 -0500
In-Reply-To: <20141111170711.15976.44062.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Intel drivers were pretty much just using the plain vanilla GFP flags
in their calls to __skb_alloc_page so this change makes it so that they use
netdev_alloc_page which just uses GFP_ATOMIC for the gfp_flags value.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +--
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index e645af4..73457ed 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -83,7 +83,7 @@ static bool fm10k_alloc_mapped_page(struct fm10k_ring *rx_ring,
 		return true;
 
 	/* alloc new page for storage */
-	page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+	page = dev_alloc_page();
 	if (unlikely(!page)) {
 		rx_ring->rx_stats.alloc_failed++;
 		return false;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a2d72a8..1e35fae 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6988,7 +6988,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 		return true;
 
 	/* alloc new page for storage */
-	page = __skb_alloc_page(GFP_ATOMIC | __GFP_COLD, NULL);
+	page = dev_alloc_page();
 	if (unlikely(!page)) {
 		rx_ring->rx_stats.alloc_failed++;
 		return false;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3..7405478 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1440,8 +1440,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	/* alloc new page for storage */
 	if (likely(!page)) {
-		page = __skb_alloc_pages(GFP_ATOMIC | __GFP_COLD | __GFP_COMP,
-					 bi->skb, ixgbe_rx_pg_order(rx_ring));
+		page = dev_alloc_pages(ixgbe_rx_pg_order(rx_ring));
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_rx_page_failed++;
 			return false;
