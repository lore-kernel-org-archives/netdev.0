From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCHv3 2/4] rds: ib: remove redundant ib_dealloc_fmr
Date: Mon, 13 Mar 2017 01:43:46 -0400
Message-ID: <1489383828-7699-3-git-send-email-yanjun.zhu@oracle.com>
References: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49921 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdCMFoJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 01:44:09 -0400
In-Reply-To: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function ib_dealloc_fmr will never be called. As such, it should
be removed.

Cc: Joe Jin <joe.jin@oracle.com>
Cc: Junxiao Bi <junxiao.bi@oracle.com>
Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>
Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
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
