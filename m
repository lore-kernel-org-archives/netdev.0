From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qed: Remove useless set memory to zero use memset()
Date: Tue, 18 Oct 2016 15:54:50 +0000
Message-ID: <1476806090-4456-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, everest-linux-l2@qlogic.com,
        netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33310 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965017AbcJRPzK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 11:55:10 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so12061249pfa.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 08:55:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

The memory return by kzalloc() has already be set to zero, so
remove useless memset(0).

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index f3a825a..6a353ff 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -2658,7 +2658,6 @@ static int qed_roce_ll2_start(struct qed_dev *cdev,
 		DP_ERR(cdev, "qed roce ll2 start: failed memory allocation\n");
 		return -ENOMEM;
 	}
-	memset(roce_ll2, 0, sizeof(*roce_ll2));
 	roce_ll2->handle = QED_LL2_UNUSED_HANDLE;
 	roce_ll2->cbs = params->cbs;
 	roce_ll2->cb_cookie = params->cb_cookie;
