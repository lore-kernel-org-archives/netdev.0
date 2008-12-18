From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] bnx2: Fix bug in bnx2_free_rx_mem().
Date: Wed, 17 Dec 2008 18:59:09 -0800
Message-ID: <1229569149-18954-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1166 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967AbYLRCvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 21:51:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DMA memory for the jumbo rx page rings was freed incorrectly using the
wrong local variable as the array index.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a1a3d0e..9e8222f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -543,9 +543,9 @@ bnx2_free_rx_mem(struct bnx2 *bp)
 		for (j = 0; j < bp->rx_max_pg_ring; j++) {
 			if (rxr->rx_pg_desc_ring[j])
 				pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
-						    rxr->rx_pg_desc_ring[i],
-						    rxr->rx_pg_desc_mapping[i]);
-			rxr->rx_pg_desc_ring[i] = NULL;
+						    rxr->rx_pg_desc_ring[j],
+						    rxr->rx_pg_desc_mapping[j]);
+			rxr->rx_pg_desc_ring[j] = NULL;
 		}
 		if (rxr->rx_pg_ring)
 			vfree(rxr->rx_pg_ring);
-- 
1.5.6.GIT


