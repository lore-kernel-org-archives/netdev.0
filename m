From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/3] s2io: Update driver to use dma_wmb
Date: Tue, 07 Apr 2015 16:55:21 -0700
Message-ID: <20150407235521.1574.27350.stgit@ahduyck-vm-fedora22>
References: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924AbbDGXzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 19:55:22 -0400
In-Reply-To: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change updates several spots where a wmb was being used to instead use
a dma_wmb to flush out writes before updating the control portion of the
descriptor.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/neterion/s2io.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 092dcae0d4a9..1e0f72b65459 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2520,7 +2520,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 			DBG_PRINT(INFO_DBG, "%s: Could not allocate skb\n",
 				  ring->dev->name);
 			if (first_rxdp) {
-				wmb();
+				dma_wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
 			}
 			swstats->mem_alloc_fail_cnt++;
@@ -2634,7 +2634,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 		rxdp->Control_2 |= SET_RXD_MARKER;
 		if (!(alloc_tab & ((1 << rxsync_frequency) - 1))) {
 			if (first_rxdp) {
-				wmb();
+				dma_wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
 			}
 			first_rxdp = rxdp;
@@ -2649,7 +2649,7 @@ end:
 	 * and other fields are seen by adapter correctly.
 	 */
 	if (first_rxdp) {
-		wmb();
+		dma_wmb();
 		first_rxdp->Control_1 |= RXD_OWN_XENA;
 	}
 
@@ -6950,7 +6950,7 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 				}
 
 				set_rxd_buffer_size(sp, rxdp, size);
-				wmb();
+				dma_wmb();
 				/* flip the Ownership bit to Hardware */
 				rxdp->Control_1 |= RXD_OWN_XENA;
 			}
