From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Fix PHC device log
Date: Sat, 13 Apr 2013 13:38:54 -0300
Message-ID: <1365871134-6834-1-git-send-email-festevam@gmail.com>
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f170.google.com ([209.85.160.170]:65468 "EHLO
	mail-gh0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab3DMQjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 12:39:09 -0400
Received: by mail-gh0-f170.google.com with SMTP id z2so572941ghb.1
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 09:39:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Currently when booting a mx6 device we get the following on boot:

registered PHC device on eth%d

Fix it so that we can read:

registered PHC device on eth0

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 1f17ca0..62e39fe 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -380,6 +380,6 @@ void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
 		fep->ptp_clock = NULL;
 		pr_err("ptp_clock_register failed\n");
 	} else {
-		pr_info("registered PHC device on %s\n", ndev->name);
+		pr_info("registered PHC device on eth%d\n", fep->dev_id);
 	}
 }
-- 
1.7.9.5
