From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/5] cnic: Fix rq_page_table DMA address.
Date: Wed, 2 Dec 2009 17:15:38 -0800
Message-ID: <1259802939-4742-4-git-send-email-mchan@broadcom.com>
References: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2980 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456AbZLCBId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 20:08:33 -0500
In-Reply-To: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The old code mistakenly zeroed out the upper 32-bit of the DMA address.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index bb6ce8d..d78e803 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1500,9 +1500,9 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	ictx->timers_context.flags |= ISCSI_TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG;
 
 	ictx->ustorm_st_context.ring.rq.pbl_base.lo =
-		req2->rq_page_table_addr_lo & 0xffffffff;
+		req2->rq_page_table_addr_lo;
 	ictx->ustorm_st_context.ring.rq.pbl_base.hi =
-		(u64) req2->rq_page_table_addr_hi >> 32;
+		req2->rq_page_table_addr_hi;
 	ictx->ustorm_st_context.ring.rq.curr_pbe.lo = req3->qp_first_pte[0].hi;
 	ictx->ustorm_st_context.ring.rq.curr_pbe.hi = req3->qp_first_pte[0].lo;
 	ictx->ustorm_st_context.ring.r2tq.pbl_base.lo =
-- 
1.6.4.GIT


