From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] macmace: add missing platform_set_drvdata() in mace_probe()
Date: Mon, 11 Nov 2013 14:16:16 +0800
Message-ID: <CAPgLHd8tvWttse-CzOcLeAfk0jySZLRhsJ2FCWsxiGaBHfBHMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, wfp5p@virginia.edu,
	gregkh@linuxfoundation.org, joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:36472 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3KKGQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:16:17 -0500
Received: by mail-bk0-f47.google.com with SMTP id v11so1081629bkz.6
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 22:16:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add missing platform_set_drvdata() in mace_probe(), otherwise
calling platform_get_drvdata() in mac_mace_device_remove() may
returns NULL.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/apple/macmace.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 4ce8ceb..58a200d 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -211,6 +211,7 @@ static int mace_probe(struct platform_device *pdev)
 	mp = netdev_priv(dev);
 
 	mp->device = &pdev->dev;
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	dev->base_addr = (u32)MACE_BASE;
