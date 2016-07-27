From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 2/6] qed: Fix removal of spoof checking for VFs
Date: Wed, 27 Jul 2016 14:45:20 +0300
Message-ID: <1469619924-12806-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59986 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755185AbcG0Lph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 07:45:37 -0400
In-Reply-To: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver has reverse logic for checking the result of the
spoof-checking configuration. As a result, it would log that
the configuration failed [even though it succeeded], and will
no longer do anything when requested to remove the configuration,
as it's accounting of the feature will be incorrect.

Fixes: 6ddc7608258d5 ("qed*: IOV support spoof-checking")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index c325ee8..875c105 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1296,7 +1296,7 @@ static int __qed_iov_spoofchk_set(struct qed_hwfn *p_hwfn,
 	params.anti_spoofing_en = val;
 
 	rc = qed_sp_vport_update(p_hwfn, &params, QED_SPQ_MODE_EBLOCK, NULL);
-	if (rc) {
+	if (!rc) {
 		p_vf->spoof_chk = val;
 		p_vf->req_spoofchk_val = p_vf->spoof_chk;
 		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
-- 
1.9.3
