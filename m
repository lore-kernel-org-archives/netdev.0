From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Only pass pdev in fec_ptp_init()
Date: Fri,  7 Jun 2013 17:48:00 -0300
Message-ID: <1370638080-19891-1-git-send-email-festevam@gmail.com>
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f176.google.com ([209.85.213.176]:43732 "EHLO
	mail-ye0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898Ab3FGUsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 16:48:14 -0400
Received: by mail-ye0-f176.google.com with SMTP id m14so1014996yen.21
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 13:48:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Passing pdev in fec_ptp_init() is enough, since we can get ndev locally.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      | 2 +-
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 drivers/net/ethernet/freescale/fec_ptp.c  | 3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index b11cdbc..e3ed6c5 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -275,7 +275,7 @@ struct fec_enet_private {
 	struct regulator *reg_phy;
 };
 
-void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);
+void fec_ptp_init(struct platform_device *pdev);
 void fec_ptp_start_cyclecounter(struct net_device *ndev);
 int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd);
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index c42c42a..fa4a68f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1945,7 +1945,7 @@ fec_probe(struct platform_device *pdev)
 	fec_reset_phy(pdev);
 
 	if (fep->bufdesc_ex)
-		fec_ptp_init(ndev, pdev);
+		fec_ptp_init(pdev);
 
 	ret = fec_enet_init(ndev);
 	if (ret)
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 25fc960..5007e4f 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -347,8 +347,9 @@ static void fec_time_keep(unsigned long _data)
  * cyclecounter init routine and exits.
  */
 
-void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
+void fec_ptp_init(struct platform_device *pdev)
 {
+	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
 	fep->ptp_caps.owner = THIS_MODULE;
-- 
1.8.1.2
