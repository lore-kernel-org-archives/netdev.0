From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v2] fec: Fix PHC device log
Date: Sat, 13 Apr 2013 14:25:36 -0300
Message-ID: <1365873936-9521-1-git-send-email-festevam@gmail.com>
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org, joe@perches.com,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:47697 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720Ab3DMRZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 13:25:49 -0400
Received: by mail-gh0-f174.google.com with SMTP id g10so268791ghb.33
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 10:25:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Currently when booting a mx6 device we get the following on boot:

registered PHC device on eth%d

Fix it by printing the network device name only after it gets registered, so
that the following can be read now:

fec 2188000.ethernet eth0: registered PHC device 0

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Use netdev_info
- Only print the interface name after it gets registered.

 drivers/net/ethernet/freescale/fec_main.c |    3 +++
 drivers/net/ethernet/freescale/fec_ptp.c  |    2 --
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 806a56d..e8858a6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1858,6 +1858,9 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
 
+	if (fep->bufdesc_ex && fep->ptp_clock)
+		netdev_info(ndev, "registered PHC device %d\n", fep->dev_id);
+
 	return 0;
 
 failed_register:
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 1f17ca0..e040c8b 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -379,7 +379,5 @@ void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
 	if (IS_ERR(fep->ptp_clock)) {
 		fep->ptp_clock = NULL;
 		pr_err("ptp_clock_register failed\n");
-	} else {
-		pr_info("registered PHC device on %s\n", ndev->name);
 	}
 }
-- 
1.7.9.5
