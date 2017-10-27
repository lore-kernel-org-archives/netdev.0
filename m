From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] qed: Set error code for allocation failures
Date: Fri, 27 Oct 2017 09:40:20 +0300
Message-ID: <20171027064020.aq52ue4kfp5htrb5@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Ariel Elior <Ariel.Elior@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28326 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdJ0Gka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 02:40:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several places where we accidentally return success when
kcalloc() fails.

Fixes: fcb39f6c10b2 ("qed: Add mpa buffer descriptors for storing and processing mpa fpdus")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index 409041eab189..6366f2ef82b7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -2585,7 +2585,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
 	struct qed_ll2_cbs cbs;
 	u32 mpa_buff_size;
 	u16 n_ooo_bufs;
-	int rc = 0;
+	int rc;
 	int i;
 
 	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
@@ -2696,6 +2696,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
 	if (rc)
 		goto err;
 
+	rc = -ENOMEM;
 	iwarp_info->partial_fpdus = kcalloc((u16)p_hwfn->p_rdma_info->num_qps,
 					    sizeof(*iwarp_info->partial_fpdus),
 					    GFP_KERNEL);
@@ -2724,7 +2725,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
 	for (i = 0; i < data.input.rx_num_desc; i++)
 		list_add_tail(&iwarp_info->mpa_bufs[i].list_entry,
 			      &iwarp_info->mpa_buf_list);
-	return rc;
+	return 0;
 err:
 	qed_iwarp_ll2_stop(p_hwfn, p_ptt);
 
