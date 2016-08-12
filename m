From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Subject: RE: [PATCH -next] qed: Fix possible memory leak in
 qed_dcbnl_get_ieee_pfc()
Date: Fri, 12 Aug 2016 05:00:40 +0000
Message-ID: <BN6PR11MB189049E2D7F71CA1B47CDE56901F0@BN6PR11MB1890.namprd11.prod.outlook.com>
References: <1470958194-25496-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0096.outbound.protection.outlook.com ([104.47.34.96]:53703
	"EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752175AbcHLMdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 08:33:53 -0400
In-Reply-To: <1470958194-25496-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the patch.

Acked-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

-----Original Message-----
From: Wei Yongjun [mailto:weiyj.lk@gmail.com] 
Sent: 12 August 2016 05:00
To: Yuval Mintz <Yuval.Mintz@qlogic.com>; Ariel Elior <Ariel.Elior@qlogic.com>; Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Cc: Wei Yongjun <weiyj.lk@gmail.com>; Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>; netdev <netdev@vger.kernel.org>
Subject: [PATCH -next] qed: Fix possible memory leak in qed_dcbnl_get_ieee_pfc()

'dcbx_info is malloced in qed_dcbnl_get_ieee_pfc() and should be freed before leaving from the error handling cases, otherwise it will cause memory leak.

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
