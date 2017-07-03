From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next] qed: initialize ll2_syn_handle at start of function
Date: Mon, 3 Jul 2017 21:55:25 +0300
Message-ID: <1499108125-27076-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <michal.kalderon@cavium.com>, <ram.amrani@cavium.com>,
        <yuval.mintz@cavium.com>, <ariel.elior@cavium.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0079.outbound.protection.outlook.com ([104.47.36.79]:18608
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752114AbdGCSz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 14:55:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix compilation warning
qed_iwarp.c:1721:5: warning: ll2_syn_handle may be used
uninitialized in this function

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index 5cd20da..b251eba 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -1724,7 +1724,7 @@ int qed_iwarp_reject(void *rdma_cxt, struct qed_iwarp_reject_in *iparams)
 	int rc;
 
 	memset(&cm_info, 0, sizeof(cm_info));
-
+	ll2_syn_handle = p_hwfn->p_rdma_info->iwarp.ll2_syn_handle;
 	if (GET_FIELD(data->parse_flags,
 		      PARSING_AND_ERR_FLAGS_L4CHKSMWASCALCULATED) &&
 	    GET_FIELD(data->parse_flags, PARSING_AND_ERR_FLAGS_L4CHKSMERROR)) {
@@ -1740,7 +1740,6 @@ int qed_iwarp_reject(void *rdma_cxt, struct qed_iwarp_reject_in *iparams)
 		goto err;
 
 	/* Check if there is a listener for this 4-tuple+vlan */
-	ll2_syn_handle = p_hwfn->p_rdma_info->iwarp.ll2_syn_handle;
 	listener = qed_iwarp_get_listener(p_hwfn, &cm_info);
 	if (!listener) {
 		DP_VERBOSE(p_hwfn,
-- 
1.8.3.1
