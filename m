From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [net, 2/6] net: korina: define NAPI_WEIGHT
Date: Tue, 17 Jan 2017 19:32:22 +0200
Message-ID: <1484674342-22304-1-git-send-email-roman@advem.lv>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33505 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdAQRc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:32:29 -0500
Received: by mail-lf0-f66.google.com with SMTP id x1so11894586lff.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 09:32:28 -0800 (PST)
Received: from ubrain.lan ([213.175.92.61])
        by smtp.googlemail.com with ESMTPSA id t1sm2240203lja.48.2017.01.17.09.32.26
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 09:32:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 9bc375d..45bd617 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -77,6 +77,8 @@
 
 #define MII_CLOCK 1250000 	/* no more than 2.5MHz */
 
+#define NAPI_WEIGHT	64
+
 /* the following must be powers of two */
 #define KORINA_NUM_RDS	64  /* number of receive descriptors */
 #define KORINA_NUM_TDS	64  /* number of transmit descriptors */
@@ -1080,7 +1082,7 @@ static int korina_probe(struct platform_device *pdev)
 	dev->netdev_ops = &korina_netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	netif_napi_add(dev, &lp->napi, korina_poll, 64);
+	netif_napi_add(dev, &lp->napi, korina_poll, NAPI_WEIGHT);
 
 	lp->phy_addr = (((lp->rx_irq == 0x2c? 1:0) << 8) | 0x05);
 	lp->mii_if.dev = dev;
-- 
2.7.4
