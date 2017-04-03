From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH -next] qed: Add a missing error code
Date: Mon, 3 Apr 2017 21:25:22 +0300
Message-ID: <20170403182522.GA32592@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@cavium.com>, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Tomer Tayar <Tomer.Tayar@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49566 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753208AbdDCSZc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 14:25:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should be returning -ENOMEM if qed_mcp_cmd_add_elem() fails.  The
current code returns success.

Fixes: 4ed1eea82a21 ("qed: Revise MFW command locking")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 619eac845028..ff6080df2246 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -455,8 +455,10 @@ _qed_mcp_cmd_and_union(struct qed_hwfn *p_hwfn,
 	qed_mcp_reread_offsets(p_hwfn, p_ptt);
 	seq_num = ++p_hwfn->mcp_info->drv_mb_seq;
 	p_cmd_elem = qed_mcp_cmd_add_elem(p_hwfn, p_mb_params, seq_num);
-	if (!p_cmd_elem)
+	if (!p_cmd_elem) {
+		rc = -ENOMEM;
 		goto err;
+	}
 
 	__qed_mcp_cmd_and_union(p_hwfn, p_ptt, p_mb_params, seq_num);
 	spin_unlock_bh(&p_hwfn->mcp_info->cmd_lock);
