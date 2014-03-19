From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] smsc911x: Change clock warning message to debug level
Date: Wed, 19 Mar 2014 11:22:06 -0300
Message-ID: <1395238926-16126-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:58718
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933380AbaCSOWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 10:22:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since passing the clock is not mandatory, change the warning message to debug, 
so that we avoid getting the following clock failure message on every boot:

smsc911x: Driver version 2008-10-21                                             
smsc911x smsc911x (unregistered net_device): couldn't get clock -2              
libphy: smsc911x-mdio: probed                                                   
  
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 6382b7c..95e2b9a 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -439,7 +439,7 @@ static int smsc911x_request_resources(struct platform_device *pdev)
 	/* Request clock */
 	pdata->clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk))
-		netdev_warn(ndev, "couldn't get clock %li\n", PTR_ERR(pdata->clk));
+		netdev_dbg(ndev, "couldn't get clock %li\n", PTR_ERR(pdata->clk));
 
 	return ret;
 }
-- 
1.8.1.2
