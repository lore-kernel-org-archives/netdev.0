From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/9] qed: Increase verbosity of VF -> PF errors
Date: Sun, 19 Mar 2017 13:08:12 +0200
Message-ID: <1489921700-6850-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45794 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751935AbdCSLIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:37 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VFs are currently logging errors when communicating
with their PFs in a too-low verbosity that wouldn't
be shown by default. As timeouts and failed commands
are crucial for VF operability, make them appear by
default.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_vf.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 15d2855..7987865 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -134,14 +134,20 @@ static int qed_send_msg2pf(struct qed_hwfn *p_hwfn, u8 *done, u32 resp_size)
 	}
 
 	if (!*done) {
-		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
-			   "VF <-- PF Timeout [Type %d]\n",
-			   p_req->first_tlv.tl.type);
+		DP_NOTICE(p_hwfn,
+			  "VF <-- PF Timeout [Type %d]\n",
+			  p_req->first_tlv.tl.type);
 		rc = -EBUSY;
 	} else {
-		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
-			   "PF response: %d [Type %d]\n",
-			   *done, p_req->first_tlv.tl.type);
+		if ((*done != PFVF_STATUS_SUCCESS) &&
+		    (*done != PFVF_STATUS_NO_RESOURCE))
+			DP_NOTICE(p_hwfn,
+				  "PF response: %d [Type %d]\n",
+				  *done, p_req->first_tlv.tl.type);
+		else
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "PF response: %d [Type %d]\n",
+				   *done, p_req->first_tlv.tl.type);
 	}
 
 	return rc;
-- 
1.9.3
