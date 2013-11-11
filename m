From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ethernet/arc/arc_emac: add missing platform_set_drvdata() in arc_emac_probe()
Date: Mon, 11 Nov 2013 14:15:12 +0800
Message-ID: <CAPgLHd_aDFExSewd3ENBgVU1Ru9LaV2Hwg=wjaO5ygo1qXRQQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: grant.likely@linaro.org, rob.herring@calxeda.com,
	davem@davemloft.net, abrodkin@synopsys.com, vgupta@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:38110 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3KKGPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:15:13 -0500
Received: by mail-bk0-f41.google.com with SMTP id v15so243759bkz.0
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 22:15:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add missing platform_set_drvdata() in arc_emac_probe(), otherwise
calling platform_get_drvdata() in arc_emac_remove() may returns NULL.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/arc/emac_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 9e16014..cbaa7f9 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -671,6 +671,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (!ndev)
 		return -ENOMEM;
 
+	platform_set_drvdata(pdev, ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	ndev->netdev_ops = &arc_emac_netdev_ops;
