From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] rocker: set physical device for port netdevice
Date: Thu, 27 Oct 2016 14:31:09 +0200
Message-ID: <1477571469-14818-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34226 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942371AbcJ0SbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 14:31:05 -0400
Received: by mail-wm0-f68.google.com with SMTP id y138so3971187wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 11:30:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Do this so the sysfs has "device" link correctly set.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 2e81b70..6d96a0c 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2542,6 +2542,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	dev = alloc_etherdev(sizeof(struct rocker_port));
 	if (!dev)
 		return -ENOMEM;
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	rocker_port = netdev_priv(dev);
 	rocker_port->dev = dev;
 	rocker_port->rocker = rocker;
-- 
2.5.5
