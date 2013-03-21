From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] lantiq_etop: use free_netdev(netdev) instead of kfree()
Date: Thu, 21 Mar 2013 15:31:42 +0800
Message-ID: <CAPgLHd8S_MBawcZQNKvKXBWes6bg=1y32GT_UYs215htg3AkZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, jiri@resnulli.us, wfp5p@virginia.edu,
	jdmason@kudzu.us, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:48593 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757840Ab3CUHbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 03:31:44 -0400
Received: by mail-bk0-f52.google.com with SMTP id jk13so1257788bkc.39
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 00:31:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Freeing netdev without free_netdev() leads to net, tx leaks.
And it may lead to dereferencing freed pointer.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/lantiq_etop.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 6a21274..bfdb0686 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -769,7 +769,7 @@ ltq_etop_probe(struct platform_device *pdev)
 	return 0;
 
 err_free:
-	kfree(dev);
+	free_netdev(dev);
 err_out:
 	return err;
 }
