From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] cxgb4: fix signed wrap around when decrementing index idx
Date: Thu, 22 Sep 2016 18:48:58 +0100
Message-ID: <20160922174858.31922-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56425 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030559AbcIVRtB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:49:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Change predecrement compare to post decrement compare to avoid an
unsigned integer wrap-around comparison when decrementing idx in
the while loop.

For example, when idx is zero, the current situation will
predecrement idx in the while loop, wrapping idx to the maximum
signed integer and cause out of bounds reads on rxq_info->msix_tbl[idx].

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index d12a73e..42a9c8d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -367,7 +367,7 @@ int request_msix_queue_irqs_uld(struct adapter *adap, unsigned int uld_type)
 	}
 	return 0;
 unwind:
-	while (--idx >= 0) {
+	while (idx-- > 0) {
 		bmap_idx = rxq_info->msix_tbl[idx];
 		free_msix_idx_in_bmap(adap, bmap_idx);
 		free_irq(adap->msix_info_ulds[bmap_idx].vec,
-- 
2.9.3
