From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] gianfar: Call netif_carrier_off() prior to registration
Date: Tue,  3 Jun 2014 19:55:38 -0300
Message-ID: <1401836138-13253-1-git-send-email-festevam@gmail.com>
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:60668 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932485AbaFCW4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 18:56:00 -0400
Received: by mail-yk0-f180.google.com with SMTP id q9so5439791ykb.39
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 15:55:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Quoting David Miller:
"At the moment you call register_netdev() the device is visible, notifications
are sent to userspace, and userland tools can try to bring the interface up
and see the incorrect link state, before you do the netif_carrier_off().

Said another way, between the register_netdev() and netif_carrier_off() call,
userspace can see the device in an inconsistent state."

So call netif_carrier_off() prior to register_netdev().

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
This is untested

 drivers/net/ethernet/freescale/gianfar.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index a7fe6a7..861e0c9 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1384,6 +1384,9 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	gfar_hw_init(priv);
 
+	/* Carrier starts down, phylib will bring it up */
+	netif_carrier_off(dev);
+
 	err = register_netdev(dev);
 
 	if (err) {
@@ -1391,9 +1394,6 @@ static int gfar_probe(struct platform_device *ofdev)
 		goto register_fail;
 	}
 
-	/* Carrier starts down, phylib will bring it up */
-	netif_carrier_off(dev);
-
 	device_init_wakeup(&dev->dev,
 			   priv->device_flags &
 			   FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
-- 
1.8.3.2
