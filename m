From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] bfin_mac: fix error return code in bfin_mac_probe()
Date: Tue, 7 May 2013 20:23:38 +0800
Message-ID: <CAPgLHd-=Cg0hvmerge=oUJvypMU7=HcuDmAgLHNSb8Tay5OVdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: davem@davemloft.net, richardcochran@gmail.com, jiri@resnulli.us,
	gregkh@linuxfoundation.org, konszert@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:48740 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771Ab3EGMXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 08:23:40 -0400
Received: by mail-bk0-f51.google.com with SMTP id ji2so258719bkc.10
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 05:23:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/adi/bfin_mac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index ee70577..4adee4c 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1700,7 +1700,8 @@ static int bfin_mac_probe(struct platform_device *pdev)
 	}
 
 	bfin_mac_hwtstamp_init(ndev);
-	if (bfin_phc_init(ndev, &pdev->dev)) {
+	rc = bfin_phc_init(ndev, &pdev->dev);
+	if (rc) {
 		dev_err(&pdev->dev, "Cannot register PHC device!\n");
 		goto out_err_phc;
 	}
