From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 7/9] qed: Make qed_iov_mark_vf_flr() return bool
Date: Sun, 19 Mar 2017 13:08:18 +0200
Message-ID: <1489921700-6850-8-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45832 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751976AbdCSLIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:51 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c |  9 +++++----
 drivers/net/ethernet/qlogic/qed/qed_sriov.h | 10 +++++-----
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index f8498a3..d592de0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3138,9 +3138,10 @@ static int qed_iov_vf_flr_poll(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
-int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *p_disabled_vfs)
+bool qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *p_disabled_vfs)
 {
-	u16 i, found = 0;
+	bool found = false;
+	u16 i;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_IOV, "Marking FLR-ed VFs\n");
 	for (i = 0; i < (VF_MAX_STATIC / 32); i++)
@@ -3150,7 +3151,7 @@ int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *p_disabled_vfs)
 
 	if (!p_hwfn->cdev->p_iov_info) {
 		DP_NOTICE(p_hwfn, "VF flr but no IOV\n");
-		return 0;
+		return false;
 	}
 
 	/* Mark VFs */
@@ -3179,7 +3180,7 @@ int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *p_disabled_vfs)
 			 * VF flr until ACKs, we're safe.
 			 */
 			p_flr[rel_vf_id / 64] |= 1ULL << (rel_vf_id % 64);
-			found = 1;
+			found = true;
 		}
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index a896058..8e96b1d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -348,9 +348,9 @@ int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
  * @param p_hwfn
  * @param disabled_vfs - bitmask of all VFs on path that were FLRed
  *
- * @return 1 iff one of the PF's vfs got FLRed. 0 otherwise.
+ * @return true iff one of the PF's vfs got FLRed. false otherwise.
  */
-int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *disabled_vfs);
+bool qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *disabled_vfs);
 
 /**
  * @brief Search extended TLVs in request/reply buffer.
@@ -407,10 +407,10 @@ static inline int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
 	return -EINVAL;
 }
 
-static inline int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn,
-				      u32 *disabled_vfs)
+static inline bool qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn,
+				       u32 *disabled_vfs)
 {
-	return 0;
+	return false;
 }
 
 static inline void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first)
-- 
1.9.3
