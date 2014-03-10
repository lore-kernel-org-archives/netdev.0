From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv5 net-next 12/31] iw_cxgb4: Fix incorrect BUG_ON conditions
Date: Mon, 10 Mar 2014 22:38:09 +0530
Message-ID: <1394471308-4304-13-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

Based on original work from Jay Hernandez <jay-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cq.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index c0673ac..59f7601 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -603,7 +603,7 @@ proc_cqe:
 	 */
 	if (SQ_TYPE(hw_cqe)) {
 		int idx = CQE_WRID_SQ_IDX(hw_cqe);
-		BUG_ON(idx > wq->sq.size);
+		BUG_ON(idx >= wq->sq.size);
 
 		/*
 		* Account for any unsignaled completions completed by
@@ -617,7 +617,7 @@ proc_cqe:
 			wq->sq.in_use -= wq->sq.size + idx - wq->sq.cidx;
 		else
 			wq->sq.in_use -= idx - wq->sq.cidx;
-		BUG_ON(wq->sq.in_use < 0 && wq->sq.in_use < wq->sq.size);
+		BUG_ON(wq->sq.in_use <= 0 && wq->sq.in_use >= wq->sq.size);
 
 		wq->sq.cidx = (uint16_t)idx;
 		PDBG("%s completing sq idx %u\n", __func__, wq->sq.cidx);
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
