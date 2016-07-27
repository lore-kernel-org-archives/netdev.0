From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 5/6] qed: Correct min bandwidth for 100g
Date: Wed, 27 Jul 2016 14:45:23 +0300
Message-ID: <1469619924-12806-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59993 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755310AbcG0Lpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 07:45:44 -0400
In-Reply-To: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver uses reverse logic when checking if minimum
bandwidth configuration applied, causing it to
configure the guarantee only on the first hw-function.

Fixes: a0d26d5a4fc8 ("qed*: Don't reset statistics on inner reload")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2d89e8c..9e305d5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2089,7 +2089,7 @@ int qed_configure_vport_wfq(struct qed_dev *cdev, u16 vp_id, u32 rate)
 
 		rc = __qed_configure_vport_wfq(p_hwfn, p_ptt, vp_id, rate);
 
-		if (!rc) {
+		if (rc) {
 			qed_ptt_release(p_hwfn, p_ptt);
 			return rc;
 		}
-- 
1.9.3
