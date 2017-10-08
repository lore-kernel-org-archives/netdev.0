From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] qed: Delete redundant check on dcb_app priority
Date: Sun,  8 Oct 2017 23:46:47 +0100
Message-ID: <1507502807-19767-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: Ariel Elior <Ariel.Elior@cavium.com>, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dcb_app priority is unsigned thus checking whether it is less than zero
is redundant.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 8f6ccc0..6e15d3c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -2308,7 +2308,7 @@ static int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
 
 	DP_VERBOSE(hwfn, QED_MSG_DCB, "selector = %d protocol = %d pri = %d\n",
 		   app->selector, app->protocol, app->priority);
-	if (app->priority < 0 || app->priority >= QED_MAX_PFC_PRIORITIES) {
+	if (app->priority >= QED_MAX_PFC_PRIORITIES) {
 		DP_INFO(hwfn, "Invalid priority %d\n", app->priority);
 		return -EINVAL;
 	}
-- 
2.7.4
