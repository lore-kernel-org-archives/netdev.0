From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] qlge: add missing free_netdev() on error in qlge_probe()
Date: Thu, 23 May 2013 17:09:50 +0800
Message-ID: <CAPgLHd-8NxBN2-x2zzjgbVNj4E_4bhVqdTi1HmxMh5pawXPKZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:43533 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756588Ab3EWJJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 05:09:52 -0400
Received: by mail-bk0-f54.google.com with SMTP id it16so1303488bkc.41
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 02:09:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing free_netdev() before return from function
qlge_probe() in the error handling case.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index e04d471..2553cf4 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4717,6 +4717,7 @@ static int qlge_probe(struct pci_dev *pdev,
 		dev_err(&pdev->dev, "net device registration failed.\n");
 		ql_release_all(pdev);
 		pci_disable_device(pdev);
+		free_netdev(ndev);
 		return err;
 	}
 	/* Start up the timer to trigger EEH if
