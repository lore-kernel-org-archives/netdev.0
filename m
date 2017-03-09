From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCHv2 3/5] rds: ib: remove redundant ib_dealloc_fmr
Date: Thu,  9 Mar 2017 04:20:43 -0500
Message-ID: <1489051243-27108-1-git-send-email-yanjun.zhu@oracle.com>
References: <cffc93fa-f4e6-e61e-54c6-67d6501dd78c@suse.de>
To: jthumshirn-l3A5Bk7waGM@public.gmane.org, santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cffc93fa-f4e6-e61e-54c6-67d6501dd78c-l3A5Bk7waGM@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The function ib_dealloc_fmr will never be called. As such, it should
be removed.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
Change from v1 to v2:
  remove ibmr NULL test.

 net/rds/ib_fmr.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
index 4fe8f4f..249ae1c 100644
--- a/net/rds/ib_fmr.c
+++ b/net/rds/ib_fmr.c
@@ -78,12 +78,9 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
 	return ibmr;
 
 out_no_cigar:
-	if (ibmr) {
-		if (fmr->fmr)
-			ib_dealloc_fmr(fmr->fmr);
-		kfree(ibmr);
-	}
+	kfree(ibmr);
 	atomic_dec(&pool->item_count);
+
 	return ERR_PTR(err);
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
