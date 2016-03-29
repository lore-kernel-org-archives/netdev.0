From: Colin King <colin.king@canonical.com>
Subject: [PATCH] qed: initialize return rc to avoid returning garbage
Date: Tue, 29 Mar 2016 18:00:50 +0100
Message-ID: <1459270850-16177-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

in the case where qed_slowpath_irq_req is not called, rc is not
assigned and so qed_int_igu_enable will return a garbage value.
Fix this by initializing rc to 0.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index ffd0acc..2017b01 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -2750,7 +2750,7 @@ void qed_int_igu_enable_int(struct qed_hwfn *p_hwfn,
 int qed_int_igu_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 		       enum qed_int_mode int_mode)
 {
-	int rc;
+	int rc = 0;
 
 	/* Configure AEU signal change to produce attentions */
 	qed_wr(p_hwfn, p_ptt, IGU_REG_ATTENTION_ENABLE, 0);
-- 
2.7.4
