From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: macb: add missing free_netdev() on error in macb_probe()
Date: Fri, 12 Aug 2016 15:43:54 +0000
Message-ID: <1471016634-32320-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33763 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbcHLPoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:44:01 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so1719449pfe.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:44:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the missing free_netdev() before return from function macb_probe()
in the platform_get_irq() error handling case.

Fixes: c69618b3e4f2 ("net/macb: fix probe sequence to setup clocks earlier")
Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6b797e3..dbce938 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2985,7 +2985,7 @@ static int macb_probe(struct platform_device *pdev)
 	dev->irq = platform_get_irq(pdev, 0);
 	if (dev->irq < 0) {
 		err = dev->irq;
-		goto err_disable_clocks;
+		goto err_out_free_netdev;
 	}
 
 	mac = of_get_mac_address(np);
