From: <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 6/7] qed: Zero-out the buffer paased to dcbx_query() API
Date: Fri, 21 Oct 2016 04:43:44 -0400
Message-ID: <1477039425-31341-7-git-send-email-sudarsana.kalluru@cavium.com>
References: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>, <manish.chopra@cavium.com>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49046 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934229AbcJUJaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:30:02 -0400
In-Reply-To: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

qed_dcbx_query_params() implementation populate the values to input
buffer based on the dcbx mode and, the current negotiated state/params,
the caller of this API need to memset the buffer to zero.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 130da1c..a4789a9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1190,6 +1190,7 @@ int qed_dcbx_get_config_params(struct qed_hwfn *p_hwfn,
 	if (!dcbx_info)
 		return -ENOMEM;
 
+	memset(dcbx_info, 0, sizeof(*dcbx_info));
 	rc = qed_dcbx_query_params(p_hwfn, dcbx_info, QED_DCBX_OPERATIONAL_MIB);
 	if (rc) {
 		kfree(dcbx_info);
@@ -1225,6 +1226,7 @@ static struct qed_dcbx_get *qed_dcbnl_get_dcbx(struct qed_hwfn *hwfn,
 	if (!dcbx_info)
 		return NULL;
 
+	memset(dcbx_info, 0, sizeof(*dcbx_info));
 	if (qed_dcbx_query_params(hwfn, dcbx_info, type)) {
 		kfree(dcbx_info);
 		return NULL;
-- 
1.8.3.1
