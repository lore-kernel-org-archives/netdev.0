From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH v2] bna: add missing iounmap() on error in bnad_init()
Date: Mon, 13 May 2013 22:26:06 +0800
Message-ID: <CAPgLHd_6i7LkoHB8GpcwF0=3ZD=Cs9Cd0JryPibMLS_j1XmRKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: rmody@brocade.com, sergei.shtylyov@cogentembedded.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58140 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab3EMO0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 10:26:07 -0400
Received: by mail-bk0-f46.google.com with SMTP id my1so302087bkb.19
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 07:26:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing iounmap() before return from bnad_init()
in the error handling case.
Introduced by commit 01b54b1451853593739816a392485c4e2bee7dda
(bna: tx rx cleanup fix).

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
v1 -> v2: remove needless empty line
---
 drivers/net/ethernet/brocade/bna/bnad.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ce4a030..07f7ef0 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3236,9 +3236,10 @@ bnad_init(struct bnad *bnad,
 
 	sprintf(bnad->wq_name, "%s_wq_%d", BNAD_NAME, bnad->id);
 	bnad->work_q = create_singlethread_workqueue(bnad->wq_name);
-
-	if (!bnad->work_q)
+	if (!bnad->work_q) {
+		iounmap(bnad->bar0);
 		return -ENOMEM;
+	}
 
 	return 0;
 }
