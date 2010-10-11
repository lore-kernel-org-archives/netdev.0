From: Paul Fertser <fercerpav@gmail.com>
Subject: [PATCH] b44: fix carrier detection on bind
Date: Tue, 12 Oct 2010 02:42:30 +0400
Message-ID: <1286836950-3161-1-git-send-email-fercerpav@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Fertser <fercerpav@gmail.com>, stable@kernel.org
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:41543 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab0JKWnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 18:43:00 -0400
Received: by ewy20 with SMTP id 20so854158ewy.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 15:42:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For carrier detection to work properly when binding the driver with a cable
unplugged, netif_carrier_off() should be called after register_netdev(),
not before.

Signed-off-by: Paul Fertser <fercerpav@gmail.com>
Cc: stable@kernel.org
---

Without this it's quite annoying to boot a laptop without ethernet
connection as the userspace is getting confused and can even add a default
route through a non-functional interface (when it's configured to use
static ip).

 drivers/net/b44.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 37617ab..d711eb6 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2161,8 +2161,6 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 	dev->irq = sdev->irq;
 	SET_ETHTOOL_OPS(dev, &b44_ethtool_ops);
 
-	netif_carrier_off(dev);
-
 	err = ssb_bus_powerup(sdev->bus, 0);
 	if (err) {
 		dev_err(sdev->dev,
@@ -2204,6 +2202,8 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 		goto err_out_powerdown;
 	}
 
+	netif_carrier_off(dev);
+
 	ssb_set_drvdata(sdev, dev);
 
 	/* Chip reset provides power to the b44 MAC & PCI cores, which
-- 
1.7.2.2

