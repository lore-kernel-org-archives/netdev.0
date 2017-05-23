From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 08/11] qed: Enable RoCE parser searching on fp init
Date: Tue, 23 May 2017 09:41:25 +0300
Message-ID: <1495521688-27669-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0072.outbound.protection.outlook.com ([104.47.32.72]:45664
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965820AbdEWGmz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:42:55 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>

Since we're closing the parser searching for RDMA when stoping the
fastpath, we need to re-enable it when starting the fastpath once again.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 3262aaa..072d950 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1948,6 +1948,13 @@ int qed_hw_start_fastpath(struct qed_hwfn *p_hwfn)
 	if (!p_ptt)
 		return -EAGAIN;
 
+	/* If roce info is allocated it means roce is initialized and should
+	 * be enabled in searcher.
+	 */
+	if (p_hwfn->p_rdma_info &&
+	    p_hwfn->b_rdma_enabled_in_prs)
+		qed_wr(p_hwfn, p_ptt, p_hwfn->rdma_prs_search_reg, 0x1);
+
 	/* Re-open incoming traffic */
 	qed_wr(p_hwfn, p_ptt, NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF, 0x0);
 	qed_ptt_release(p_hwfn, p_ptt);
-- 
1.9.3
