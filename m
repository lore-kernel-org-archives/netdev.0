From: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [net-next PATCH 4/5] fm10k/igb/ixgbe: Replace __skb_alloc_page with
 netdev_alloc_page
Date: Mon, 10 Nov 2014 11:52:21 -0800
Message-ID: <20141110195221.16182.16080.stgit@ahduyck-vm-fedora20>
References: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Intel drivers were pretty much just using the plain vanilla GFP flags
in their calls to __skb_alloc_page so this change makes it so that they use
netdev_alloc_page which just uses GFP_ATOMIC for the gfp_flags value.

Cc: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Matthew Vick <matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c     |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +--
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index e645af4..64d82c5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -83,7 +83,7 @@ static bool fm10k_alloc_mapped_page(struct fm10k_ring *rx_ring,
 		return true;
 
 	/* alloc new page for storage */
-	page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+	page = netdev_alloc_page();
 	if (unlikely(!page)) {
 		rx_ring->rx_stats.alloc_failed++;
 		return false;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a2d72a8..1245a86 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6988,7 +6988,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 		return true;
 
 	/* alloc new page for storage */
-	page = __skb_alloc_page(GFP_ATOMIC | __GFP_COLD, NULL);
+	page = netdev_alloc_page();
 	if (unlikely(!page)) {
 		rx_ring->rx_stats.alloc_failed++;
 		return false;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3..8e4ba8c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1440,8 +1440,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 
 	/* alloc new page for storage */
 	if (likely(!page)) {
-		page = __skb_alloc_pages(GFP_ATOMIC | __GFP_COLD | __GFP_COMP,
-					 bi->skb, ixgbe_rx_pg_order(rx_ring));
+		page = netdev_alloc_pages(ixgbe_rx_pg_order(rx_ring));
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_rx_page_failed++;
 			return false;

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
