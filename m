From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 3/5] qed: Tell QM the number of tasks
Date: Tue, 9 May 2017 15:07:49 +0300
Message-ID: <1494331671-16273-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0046.outbound.protection.outlook.com ([104.47.42.46]:54048
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753523AbdEIMIT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:08:19 -0400
In-Reply-To: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver doesn't pass the number of tasks to the QM init logic
which would cause back-pressure in scenarios requiring many tasks
[E.g., using max MRs] and thus reduced performance.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index b3aaa98..6948457 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -1460,6 +1460,7 @@ void qed_qm_init_pf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	params.is_first_pf = p_hwfn->first_on_engine;
 	params.num_pf_cids = iids.cids;
 	params.num_vf_cids = iids.vf_cids;
+	params.num_tids = iids.tids;
 	params.start_pq = qm_info->start_pq;
 	params.num_pf_pqs = qm_info->num_pqs - qm_info->num_vf_pqs;
 	params.num_vf_pqs = qm_info->num_vf_pqs;
-- 
1.9.3
