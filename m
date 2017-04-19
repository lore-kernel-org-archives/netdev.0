From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 4/4] qed: Fix issue in populating the PFC config paramters.
Date: Wed, 19 Apr 2017 03:19:55 -0700
Message-ID: <20170419101955.26444-5-sudarsana.kalluru@cavium.com>
References: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0071.outbound.protection.outlook.com ([104.47.42.71]:60480
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1762171AbdDSKUd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 06:20:33 -0400
In-Reply-To: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change ieee_setpfc() callback implementation to populate traffic class
count with the user provided value.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 8f0783a..a6e2bbe 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -2082,6 +2082,8 @@ static int qed_dcbnl_ieee_setpfc(struct qed_dev *cdev, struct ieee_pfc *pfc)
 	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++)
 		dcbx_set.config.params.pfc.prio[i] = !!(pfc->pfc_en & BIT(i));
 
+	dcbx_set.config.params.pfc.max_tc = pfc->pfc_cap;
+
 	ptt = qed_ptt_acquire(hwfn);
 	if (!ptt)
 		return -EINVAL;
-- 
1.8.3.1
