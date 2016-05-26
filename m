From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 5/8] qed: Save min/max accross dcbx-change
Date: Thu, 26 May 2016 11:01:21 +0300
Message-ID: <1464249684-976-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32615 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753242AbcEZIBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:49 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When DCBx re-negotiation is occurring, the PF's configurations for
maximum and minimum bandwidth guarantees are currently lost.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 7aeed2f..920eadd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -161,6 +161,8 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
 	struct init_qm_port_params *p_qm_port;
 	u16 num_pqs, multi_cos_tcs = 1;
+	u8 pf_wfq = qm_info->pf_wfq;
+	u32 pf_rl = qm_info->pf_rl;
 	u16 num_vfs = 0;
 
 #ifdef CONFIG_QED_SRIOV
@@ -269,10 +271,10 @@ static int qed_init_qm_info(struct qed_hwfn *p_hwfn, bool b_sleepable)
 	for (i = 0; i < qm_info->num_vports; i++)
 		qm_info->qm_vport_params[i].vport_wfq = 1;
 
-	qm_info->pf_wfq = 0;
-	qm_info->pf_rl = 0;
 	qm_info->vport_rl_en = 1;
 	qm_info->vport_wfq_en = 1;
+	qm_info->pf_rl = pf_rl;
+	qm_info->pf_wfq = pf_wfq;
 
 	return 0;
 
-- 
1.9.3
