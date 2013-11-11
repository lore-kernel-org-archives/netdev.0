From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] xtsonic: add missing platform_set_drvdata() in xtsonic_probe()
Date: Mon, 11 Nov 2013 14:17:17 +0800
Message-ID: <CAPgLHd8pm_g=PCNJXo2iEvuWykyP_ewnsfS9FQ2qmQwRGjVuCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, wfp5p@virginia.edu,
	gregkh@linuxfoundation.org, michael.opdenacker@free-electrons.com,
	joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:43863 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab3KKGRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:17:18 -0500
Received: by mail-bk0-f51.google.com with SMTP id my12so1476197bkb.24
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 22:17:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add missing platform_set_drvdata() in xtsonic_probe(), otherwise
calling platform_get_drvdata() in xtsonic_device_remove() may
returns NULL.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/natsemi/xtsonic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index 4da172a..7007d21 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -264,6 +264,7 @@ int xtsonic_probe(struct platform_device *pdev)
 
 	lp = netdev_priv(dev);
 	lp->device = &pdev->dev;
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	netdev_boot_setup_check(dev);
 
