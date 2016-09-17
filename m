From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] cxgb4: Fix return value check in cfg_queues_uld()
Date: Sat, 17 Sep 2016 15:52:17 +0000
Message-ID: <1474127537-14230-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34103 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752346AbcIQPw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 11:52:26 -0400
Received: by mail-pa0-f66.google.com with SMTP id vz6so4773829pab.1
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 08:52:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix the retrn value check which testing the wrong variable
in cfg_queues_uld().

Fixes: 94cdb8bb993a ("cxgb4: Add support for dynamic allocation of
resources for ULD")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 5d402ba..4d1de62 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -245,7 +245,7 @@ int cfg_queues_uld(struct adapter *adap, unsigned int uld_type,
 	}
 
 	rxq_info->rspq_id = kcalloc(nrxq, sizeof(unsigned short), GFP_KERNEL);
-	if (!rxq_info->uldrxq) {
+	if (!rxq_info->rspq_id) {
 		kfree(rxq_info->uldrxq);
 		kfree(rxq_info);
 		return -ENOMEM;
