From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 05/17] RDS: RDMA: fix the ib_map_mr_sg_zbva() argument
Date: Mon,  2 Jan 2017 14:45:40 -0800
Message-ID: <1483397152-8307-6-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50536 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756906AbdABWqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:46:12 -0500
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes warning: Using plain integer as NULL pointer

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_frmr.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_frmr.c b/net/rds/ib_frmr.c
index d921adc..66b3d62 100644
--- a/net/rds/ib_frmr.c
+++ b/net/rds/ib_frmr.c
@@ -104,14 +104,15 @@ static int rds_ib_post_reg_frmr(struct rds_ib_mr *ibmr)
 	struct rds_ib_frmr *frmr = &ibmr->u.frmr;
 	struct ib_send_wr *failed_wr;
 	struct ib_reg_wr reg_wr;
-	int ret;
+	int ret, off = 0;
 
 	while (atomic_dec_return(&ibmr->ic->i_fastreg_wrs) <= 0) {
 		atomic_inc(&ibmr->ic->i_fastreg_wrs);
 		cpu_relax();
 	}
 
-	ret = ib_map_mr_sg_zbva(frmr->mr, ibmr->sg, ibmr->sg_len, 0, PAGE_SIZE);
+	ret = ib_map_mr_sg_zbva(frmr->mr, ibmr->sg, ibmr->sg_len,
+				&off, PAGE_SIZE);
 	if (unlikely(ret != ibmr->sg_len))
 		return ret < 0 ? ret : -EINVAL;
 
-- 
1.9.1
