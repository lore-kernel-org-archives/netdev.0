From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/5] qed: Correct PF-sanity check
Date: Sun, 15 May 2016 14:48:05 +0300
Message-ID: <1463312889-19351-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:53077 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752420AbcEOLsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 07:48:20 -0400
In-Reply-To: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems like something broke in commit 1408cc1fa48c ("qed: Introduce VFs")
and the function no longer verifies that the vf is indeed a valid one.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index d4df406..2c4f9b0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -476,12 +476,12 @@ int qed_iov_hw_info(struct qed_hwfn *p_hwfn)
 static bool qed_iov_pf_sanity_check(struct qed_hwfn *p_hwfn, int vfid)
 {
 	/* Check PF supports sriov */
-	if (!IS_QED_SRIOV(p_hwfn->cdev) || !IS_PF_SRIOV_ALLOC(p_hwfn))
+	if (IS_VF(p_hwfn->cdev) || !IS_QED_SRIOV(p_hwfn->cdev) ||
+	    !IS_PF_SRIOV_ALLOC(p_hwfn))
 		return false;
 
 	/* Check VF validity */
-	if (IS_VF(p_hwfn->cdev) || !IS_QED_SRIOV(p_hwfn->cdev) ||
-	    !IS_PF_SRIOV_ALLOC(p_hwfn))
+	if (!qed_iov_is_valid_vfid(p_hwfn, vfid, true))
 		return false;
 
 	return true;
-- 
1.9.3
