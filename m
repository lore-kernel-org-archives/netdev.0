From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Free MSIX vectors when unregistering the device from bnxt_re.
Date: Wed, 23 Aug 2017 19:34:04 -0400
Message-ID: <1503531245-4046-3-git-send-email-michael.chan@broadcom.com>
References: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:36027 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdHWXeW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 19:34:22 -0400
Received: by mail-qk0-f169.google.com with SMTP id o63so8695313qkb.3
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 16:34:21 -0700 (PDT)
In-Reply-To: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take back ownership of the MSIX vectors when unregistering the device
from bnxt_re.

Fixes: a588e4580a7e ("bnxt_en: Add interface to support RDMA driver.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
index 77da75a..997e10e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ulp.c
@@ -84,6 +84,8 @@ static int bnxt_unregister_dev(struct bnxt_en_dev *edev, int ulp_id)
 
 		max_stat_ctxs = bnxt_get_max_func_stat_ctxs(bp);
 		bnxt_set_max_func_stat_ctxs(bp, max_stat_ctxs + 1);
+		if (ulp->msix_requested)
+			edev->en_ops->bnxt_free_msix(edev, ulp_id);
 	}
 	if (ulp->max_async_event_id)
 		bnxt_hwrm_func_rgtr_async_events(bp, NULL, 0);
-- 
1.8.3.1
