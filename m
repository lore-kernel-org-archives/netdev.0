From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 8/9] qed: Raise verbosity of Malicious VF indications
Date: Sun, 19 Mar 2017 13:08:19 +0200
Message-ID: <1489921700-6850-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45835 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752002AbdCSLIw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:52 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Malicious VF existance should be interesting enough for the
hyperuser. Change the PF indication that one of its child VF
became malicious to appear by default.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index d592de0..0d37d73 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3386,11 +3386,17 @@ static void qed_sriov_vfpf_malicious(struct qed_hwfn *p_hwfn,
 	if (!p_vf)
 		return;
 
-	DP_INFO(p_hwfn,
-		"VF [%d] - Malicious behavior [%02x]\n",
-		p_vf->abs_vf_id, p_data->err_id);
+	if (!p_vf->b_malicious) {
+		DP_NOTICE(p_hwfn,
+			  "VF [%d] - Malicious behavior [%02x]\n",
+			  p_vf->abs_vf_id, p_data->err_id);
 
-	p_vf->b_malicious = true;
+		p_vf->b_malicious = true;
+	} else {
+		DP_INFO(p_hwfn,
+			"VF [%d] - Malicious behavior [%02x]\n",
+			p_vf->abs_vf_id, p_data->err_id);
+	}
 }
 
 int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
-- 
1.9.3
