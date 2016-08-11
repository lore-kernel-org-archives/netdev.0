From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qed: Fix possible memory leak in qed_dcbnl_get_ieee_pfc()
Date: Thu, 11 Aug 2016 23:29:54 +0000
Message-ID: <1470958194-25496-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33336 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbcHKXaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 19:30:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id i6so479693pfe.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 16:30:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'dcbx_info is malloced in qed_dcbnl_get_ieee_pfc() and should be freed
before leaving from the error handling cases, otherwise it will cause
memory leak.

Fixes: a1d8d8a51e83 ("qed: Add dcbnl support.")
Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 226cb08..b900dfb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1968,6 +1968,7 @@ static int qed_dcbnl_get_ieee_pfc(struct qed_dev *cdev,
 
 	if (!dcbx_info->operational.ieee) {
 		DP_INFO(hwfn, "DCBX is not enabled/operational in IEEE mode\n");
+		kfree(dcbx_info);
 		return -EINVAL;
 	}
