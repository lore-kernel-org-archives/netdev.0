From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 4/4] qed: Update app count when adding a new dcbx app entry to the table.
Date: Mon, 8 Aug 2016 21:57:43 -0400
Message-ID: <1470707863-11712-5-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59015 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752499AbcHIClE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 22:41:04 -0400
In-Reply-To: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

App count is not updated while adding new app entry to the dcbx app table.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index b157a6a..226cb08 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1707,8 +1707,10 @@ static int qed_dcbnl_setapp(struct qed_dev *cdev,
 		if ((entry->ethtype == ethtype) && (entry->proto_id == idval))
 			break;
 		/* First empty slot */
-		if (!entry->proto_id)
+		if (!entry->proto_id) {
+			dcbx_set.config.params.num_app_entries++;
 			break;
+		}
 	}
 
 	if (i == QED_DCBX_MAX_APP_PROTOCOL) {
@@ -2228,8 +2230,10 @@ int qed_dcbnl_ieee_setapp(struct qed_dev *cdev, struct dcb_app *app)
 		    (entry->proto_id == app->protocol))
 			break;
 		/* First empty slot */
-		if (!entry->proto_id)
+		if (!entry->proto_id) {
+			dcbx_set.config.params.num_app_entries++;
 			break;
+		}
 	}
 
 	if (i == QED_DCBX_MAX_APP_PROTOCOL) {
-- 
1.8.3.1
