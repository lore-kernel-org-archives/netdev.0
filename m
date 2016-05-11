From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next 3/4] net: w5100: increase TX timeout period
Date: Wed, 11 May 2016 15:30:26 +0900
Message-ID: <1462948227-21276-4-git-send-email-akinobu.mita@gmail.com>
References: <1462948227-21276-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35553 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbcEKGao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 02:30:44 -0400
Received: by mail-pa0-f66.google.com with SMTP id zy2so3420654pac.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 23:30:44 -0700 (PDT)
In-Reply-To: <1462948227-21276-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This increases TX timeout period from one second to 5 seconds which is
default value defined in net/sched/sch_generic.c.

The one second timeout is too short for W5100 with SPI interface mode
which doesn't support burst READ/WRITE processing in the SPI transfer.
If the packet is transmitted while RX packets are being received at a
very high rate, the TX transmittion work in the workqueue is delayed
and the watchdog timer is expired.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/wiznet/w5100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index c80438c..f649f1c 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -1142,7 +1142,7 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 
 	ndev->netdev_ops = &w5100_netdev_ops;
 	ndev->ethtool_ops = &w5100_ethtool_ops;
-	ndev->watchdog_timeo = HZ;
+	ndev->watchdog_timeo = 5 * HZ;
 	netif_napi_add(ndev, &priv->napi, w5100_napi_poll, 16);
 
 	/* This chip doesn't support VLAN packets with normal MTU,
-- 
2.7.4
