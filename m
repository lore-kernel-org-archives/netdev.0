From: Vincenzo Maffione <v.maffione@gmail.com>
Subject: [PATCH] drivers: net: xen-netfront: remove unused arrays
Date: Tue, 15 Apr 2014 19:39:39 +0200
Message-ID: <1397583579-32162-1-git-send-email-v.maffione@gmail.com>
Cc: boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vincenzo Maffione <v.maffione@gmail.com>
To: konrad.wilk@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes some unused arrays from the netfront
private data structure.
Also removes an unused address variable.

Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>
---
Hello,
  I don't see the point in having those unused arrays in the private
structure.

Sorry if I'm missing something.

Cheers,
  Vincenzo


 drivers/net/xen-netfront.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 158b5e6..1403ac7 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -137,10 +137,6 @@ struct netfront_info {
 	grant_ref_t gref_rx_head;
 	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
 
-	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
-	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
-	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
-
 	/* Statistics */
 	struct netfront_stats __percpu *stats;
 
@@ -252,7 +248,6 @@ static void xennet_alloc_rx_buffers(struct net_device *dev)
 	RING_IDX req_prod = np->rx.req_prod_pvt;
 	grant_ref_t ref;
 	unsigned long pfn;
-	void *vaddr;
 	struct xen_netif_rx_request *req;
 
 	if (unlikely(!netif_carrier_ok(dev)))
@@ -322,7 +317,6 @@ no_skb:
 		np->grant_rx_ref[id] = ref;
 
 		pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
-		vaddr = page_address(skb_frag_page(&skb_shinfo(skb)->frags[0]));
 
 		req = RING_GET_REQUEST(&np->rx, req_prod + i);
 		gnttab_grant_foreign_access_ref(ref,
-- 
1.9.2
