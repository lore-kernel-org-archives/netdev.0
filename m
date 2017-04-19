From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 2/4] qed: Fix sending an invalid PFC error mask to MFW.
Date: Wed, 19 Apr 2017 03:19:53 -0700
Message-ID: <20170419101955.26444-3-sudarsana.kalluru@cavium.com>
References: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0088.outbound.protection.outlook.com ([104.47.37.88]:11536
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1762084AbdDSKUc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 06:20:32 -0400
In-Reply-To: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PFC error-mask value is not supported by MFW, but this bit could be
set in the pfc bit-map of the operational parameters if remote device
supports it. These operational parameters are used as basis for
populating the dcbx config parameters. User provided configs will be
applied on top of these parameters and then send them to MFW when
requested. Driver need to clear the error-mask bit before sending the
config parameters to MFW.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index c24436c..ff058a3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1008,6 +1008,8 @@ static int qed_dcbx_query_params(struct qed_hwfn *p_hwfn,
 	u8 pfc_map = 0;
 	int i;
 
+	*pfc &= ~DCBX_PFC_ERROR_MASK;
+
 	if (p_params->pfc.willing)
 		*pfc |= DCBX_PFC_WILLING_MASK;
 	else
-- 
1.8.3.1
