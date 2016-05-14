From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next v2 3/4] net: w5100: increase TX timeout period
Date: Sat, 14 May 2016 14:55:49 +0900
Message-ID: <1463205350-7089-4-git-send-email-akinobu.mita@gmail.com>
References: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33852 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbcENF4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 01:56:38 -0400
Received: by mail-pa0-f66.google.com with SMTP id yl2so9991126pac.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 22:56:38 -0700 (PDT)
In-Reply-To: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This increases TX timeout period from one second to 5 seconds which is
the default value if the driver doesn't explicitly set
net_device->watchdog_timeo.

The one second timeout is too short for W5100 with SPI interface mode
which doesn't support burst READ/WRITE processing in the SPI transfer.
If the packet is transmitted while RX packets are being received at a
very high rate, the TX transmittion work in the workqueue is delayed
and the watchdog timer is expired.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
* v2
- Remove the watchdong_timeo assignment to set default tx timeout,
  suggested by David Miller.

 drivers/net/ethernet/wiznet/w5100.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index c80438c..43fdf88 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -1142,7 +1142,6 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 
 	ndev->netdev_ops = &w5100_netdev_ops;
 	ndev->ethtool_ops = &w5100_ethtool_ops;
-	ndev->watchdog_timeo = HZ;
 	netif_napi_add(ndev, &priv->napi, w5100_napi_poll, 16);
 
 	/* This chip doesn't support VLAN packets with normal MTU,
-- 
2.7.4
