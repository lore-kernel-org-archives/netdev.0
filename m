From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 3/5] qed: Correct TM ILT lines in presence of VFs
Date: Mon, 3 Apr 2017 12:21:11 +0300
Message-ID: <1491211273-10910-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51520 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752348AbdDCJV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:21:59 -0400
In-Reply-To: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of today there's no protocol supported that requires
support from the TM hardware block and enables SRIOV,
but we should still correct the calculation to reflect
the lines required for such future VFs instead of changing
the PF's own lines.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index 259dafa..f7b1a37 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -783,8 +783,8 @@ int qed_cxt_cfg_ilt_compute(struct qed_hwfn *p_hwfn)
 
 		qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
 				     ILT_CLI_TM);
-		p_cli->pf_total_lines = curr_line - p_blk->start_line;
 
+		p_cli->vf_total_lines = curr_line - p_blk->start_line;
 		for (i = 1; i < p_mngr->vf_count; i++)
 			qed_ilt_cli_adv_line(p_hwfn, p_cli, p_blk, &curr_line,
 					     ILT_CLI_TM);
-- 
1.9.3
