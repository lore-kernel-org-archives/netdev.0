From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] bna: add missing iounmap() on error in bnad_init()
Date: Mon, 13 May 2013 15:26:21 +0800
Message-ID: <CAPgLHd8G816BcF7U6eG320w=k9Zv-yVYjt4wreyU67eSdVRERg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: rmody@brocade.com, huangj@brocade.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:48645 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab3EMH0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 03:26:22 -0400
Received: by mail-bk0-f44.google.com with SMTP id jk13so2296674bkc.31
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 00:26:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing iounmap() before return from bnad_init()
in the error handling case.
Introduced by commit 01b54b1451853593739816a392485c4e2bee7dda
(bna: tx rx cleanup fix).

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ce4a030..59da9eb 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3237,8 +3237,10 @@ bnad_init(struct bnad *bnad,
 	sprintf(bnad->wq_name, "%s_wq_%d", BNAD_NAME, bnad->id);
 	bnad->work_q = create_singlethread_workqueue(bnad->wq_name);
 
-	if (!bnad->work_q)
+	if (!bnad->work_q) {
+		iounmap(bnad->bar0);
 		return -ENOMEM;
+	}
 
 	return 0;
 }
