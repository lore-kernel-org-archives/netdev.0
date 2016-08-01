From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net] qed: Fail driver load in 100g MSI mode.
Date: Mon, 1 Aug 2016 09:08:13 -0400
Message-ID: <1470056893-16415-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:30226 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752026AbcHANze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 09:55:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

100g support is not available in MSI mode. Failing the driver load in this scenario.

Please consider applying this to `net'.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 1f13abb..c7dc34b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -659,8 +659,13 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 	struct qed_sb_cnt_info sb_cnt_info;
 	int rc;
 	int i;
-	memset(&cdev->int_params, 0, sizeof(struct qed_int_params));
 
+	if ((int_mode == QED_INT_MODE_MSI) && (cdev->num_hwfns > 1)) {
+		DP_NOTICE(cdev, "MSI mode is not supported for CMT devices\n");
+		return -EINVAL;
+	}
+
+	memset(&cdev->int_params, 0, sizeof(struct qed_int_params));
 	cdev->int_params.in.int_mode = int_mode;
 	for_each_hwfn(cdev, i) {
 		memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
-- 
1.8.3.1
