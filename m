From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 7/7] qed: Enable iSCSI Out-of-Order
Date: Tue, 14 Mar 2017 15:26:04 +0200
Message-ID: <1489497964-13734-8-git-send-email-Yuval.Mintz@cavium.com>
References: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39044 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752199AbdCNN0Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:26:25 -0400
In-Reply-To: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missing in the initial submission, qed fails to propagate qedi's
request to enable OOO to firmware.

Fixes: fc831825f99e ("qed: Add support for hardware offloaded iSCSI")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 7e73b05..098766f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -190,6 +190,9 @@ struct qed_iscsi_conn {
 	p_init->num_sq_pages_in_ring = p_params->num_sq_pages_in_ring;
 	p_init->num_r2tq_pages_in_ring = p_params->num_r2tq_pages_in_ring;
 	p_init->num_uhq_pages_in_ring = p_params->num_uhq_pages_in_ring;
+	p_init->ooo_enable = p_params->ooo_enable;
+	p_init->ll2_rx_queue_id = p_hwfn->hw_info.resc_start[QED_LL2_QUEUE] +
+				  p_params->ll2_ooo_queue_id;
 	p_init->func_params.log_page_size = p_params->log_page_size;
 	val = p_params->num_tasks;
 	p_init->func_params.num_tasks = cpu_to_le16(val);
-- 
1.9.3
