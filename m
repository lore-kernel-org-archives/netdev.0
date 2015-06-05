From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix static checker warning
Date: Fri,  5 Jun 2015 14:36:33 +0530
Message-ID: <1433495193-8658-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30421 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753907AbbFEDxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch e85c9a7abfa4: ("cxgb4/cxgb4vf: Add code to calculate T5 BAR2
Offsets for SGE Queue Registers") from Dec 3, 2014, leads to the
following static checker warning:

        drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:5358
	t4_bar2_sge_qregs()
        warn: should '(qid >> qpp_shift) << page_shift' be a 64 bit type?

This patch fixes it

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index b411098..fdda0f8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -6053,7 +6053,7 @@ int t4_bar2_sge_qregs(struct adapter *adapter,
 	 *  o The BAR2 Queue ID.
 	 *  o The BAR2 Queue ID Offset into the BAR2 page.
 	 */
-	bar2_page_offset = ((qid >> qpp_shift) << page_shift);
+	bar2_page_offset = ((u64)(qid >> qpp_shift) << page_shift);
 	bar2_qid = qid & qpp_mask;
 	bar2_qid_offset = bar2_qid * SGE_UDB_SIZE;
 
-- 
2.3.4
