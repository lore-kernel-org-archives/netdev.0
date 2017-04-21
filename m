From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 2/5] qed: Separate RoCE DCBx support for V2.
Date: Thu, 20 Apr 2017 22:31:17 -0700
Message-ID: <20170421053120.12980-3-sudarsana.kalluru@cavium.com>
References: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0053.outbound.protection.outlook.com ([104.47.36.53]:15360
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035507AbdDUFb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 01:31:57 -0400
In-Reply-To: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the older firmware there was no distinction between RoCE and RoCEv2
whereas the newer firmware (8.15.3.0) allows us to configure each
independently. Driver need to populate the RoCEv2 data in its specific
structure.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 9b4580b..d868b7e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -944,14 +944,9 @@ void qed_dcbx_set_pf_update_params(struct qed_dcbx_results *p_src,
 	p_dcb_data = &p_dest->fcoe_dcb_data;
 	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_FCOE);
 	p_dcb_data = &p_dest->roce_dcb_data;
-
-	if (p_src->arr[DCBX_PROTOCOL_ROCE].update)
-		qed_dcbx_update_protocol_data(p_dcb_data, p_src,
-					      DCBX_PROTOCOL_ROCE);
-	if (p_src->arr[DCBX_PROTOCOL_ROCE_V2].update)
-		qed_dcbx_update_protocol_data(p_dcb_data, p_src,
-					      DCBX_PROTOCOL_ROCE_V2);
-
+	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_ROCE);
+	p_dcb_data = &p_dest->rroce_dcb_data;
+	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_ROCE_V2);
 	p_dcb_data = &p_dest->iscsi_dcb_data;
 	qed_dcbx_update_protocol_data(p_dcb_data, p_src, DCBX_PROTOCOL_ISCSI);
 	p_dcb_data = &p_dest->eth_dcb_data;
-- 
1.8.3.1
