From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/9] qed: Correct default VF coalescing configuration
Date: Sun, 19 Mar 2017 13:08:15 +0200
Message-ID: <1489921700-6850-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45805 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751968AbdCSLIp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:08:45 -0400
In-Reply-To: <1489921700-6850-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When starting the VF's vport, the PF would first configure
the status blocks of the VF and then reset them.
That would cause some of the configured information to be lost -
specifically it would mean that all the VFs queues would use
the Rx coalescing state-machine of the status block.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index aea1e4c..098330e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1755,6 +1755,8 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 	vf->state = VF_ENABLED;
 	start = &mbx->req_virt->start_vport;
 
+	qed_iov_enable_vf_traffic(p_hwfn, p_ptt, vf);
+
 	/* Initialize Status block in CAU */
 	for (sb_id = 0; sb_id < vf->num_sbs; sb_id++) {
 		if (!start->sb_addr[sb_id]) {
@@ -1768,7 +1770,6 @@ static void qed_iov_vf_mbx_start_vport(struct qed_hwfn *p_hwfn,
 				    start->sb_addr[sb_id],
 				    vf->igu_sbs[sb_id], vf->abs_vf_id, 1);
 	}
-	qed_iov_enable_vf_traffic(p_hwfn, p_ptt, vf);
 
 	vf->mtu = start->mtu;
 	vf->shadow_config.inner_vlan_removal = start->inner_vlan_removal;
-- 
1.9.3
