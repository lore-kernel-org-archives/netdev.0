From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 1/2] smsc911x: Do not use netdev_dbg() when device is not registered
Date: Mon, 24 Mar 2014 12:34:23 -0300
Message-ID: <1395675264-13851-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <steve.glendinning@shawell.net>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:1526 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752521AbaCXQ33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 12:29:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With debug enabled we get the following message:

smsc911x smsc911x (unregistered net_device): couldn't get clock -2

As the device has not been registered at this point, it is better to use 
dev_dbg() instead of netdev_dbg().

CC: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 95e2b9a..c6a5e89 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -439,7 +439,8 @@ static int smsc911x_request_resources(struct platform_device *pdev)
 	/* Request clock */
 	pdata->clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk))
-		netdev_dbg(ndev, "couldn't get clock %li\n", PTR_ERR(pdata->clk));
+		dev_dbg(&pdev->dev, "couldn't get clock %li\n",
+			PTR_ERR(pdata->clk));
 
 	return ret;
 }
-- 
1.8.1.2
