From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 2/6] qed: remove unused SQ error state
Date: Sun, 30 Apr 2017 11:49:06 +0300
Message-ID: <1493542150-21826-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ram.Amrani@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0063.outbound.protection.outlook.com ([104.47.34.63]:21977
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S969800AbdD3Itg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:49:36 -0400
In-Reply-To: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

The internal RoCE SQE QP state isn't being used. Instead we mark the
QP as in regular error state.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 5d40615..01244d7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -2191,8 +2191,7 @@ static int qed_roce_modify_qp(struct qed_hwfn *p_hwfn,
 						  params->modify_flags);
 
 		return rc;
-	} else if (qp->cur_state == QED_ROCE_QP_STATE_ERR ||
-		   qp->cur_state == QED_ROCE_QP_STATE_SQE) {
+	} else if (qp->cur_state == QED_ROCE_QP_STATE_ERR) {
 		/* ->ERR */
 		rc = qed_roce_sp_modify_responder(p_hwfn, qp, true,
 						  params->modify_flags);
-- 
1.9.3
