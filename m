From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCHv3 3/4] rds: ib: add the static type to the function
Date: Mon, 13 Mar 2017 01:43:47 -0400
Message-ID: <1489383828-7699-4-git-send-email-yanjun.zhu@oracle.com>
References: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43737 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750802AbdCMFoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 01:44:10 -0400
In-Reply-To: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function rds_ib_map_fmr is used only in the ib_fmr.c
file. As such, the static type is added to limit it in this file.

Cc: Joe Jin <joe.jin@oracle.com>
Cc: Junxiao Bi <junxiao.bi@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 net/rds/ib_fmr.c | 5 +++--
 net/rds/ib_mr.h  | 2 --
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
index 249ae1c..c936b0d 100644
--- a/net/rds/ib_fmr.c
+++ b/net/rds/ib_fmr.c
@@ -84,8 +84,9 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
 	return ERR_PTR(err);
 }
 
-int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibmr,
-		   struct scatterlist *sg, unsigned int nents)
+static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev,
+			  struct rds_ib_mr *ibmr, struct scatterlist *sg,
+			  unsigned int nents)
 {
 	struct ib_device *dev = rds_ibdev->dev;
 	struct rds_ib_fmr *fmr = &ibmr->u.fmr;
diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index 5d6e98a..0ea4ab0 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -125,8 +125,6 @@ void rds_ib_mr_exit(void);
 void __rds_ib_teardown_mr(struct rds_ib_mr *);
 void rds_ib_teardown_mr(struct rds_ib_mr *);
 struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *, int);
-int rds_ib_map_fmr(struct rds_ib_device *, struct rds_ib_mr *,
-		   struct scatterlist *, unsigned int);
 struct rds_ib_mr *rds_ib_reuse_mr(struct rds_ib_mr_pool *);
 int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *, int, struct rds_ib_mr **);
 struct rds_ib_mr *rds_ib_reg_fmr(struct rds_ib_device *, struct scatterlist *,
-- 
2.7.4
