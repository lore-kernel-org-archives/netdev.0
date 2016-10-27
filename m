From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2] rocker: set physical device for port netdevice
Date: Thu, 27 Oct 2016 22:32:22 +0200
Message-ID: <1477600342-2752-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33434 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933978AbcJ0UcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:32:25 -0400
Received: by mail-wm0-f66.google.com with SMTP id m83so4403178wmc.0
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 13:32:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Do this so the sysfs has "device" link correctly set.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
 - make pdev non-const as pointerd out by kbuild test robot
---
 drivers/net/ethernet/rocker/rocker_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 2e81b70..55b2ab9 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2534,7 +2534,7 @@ static void rocker_port_dev_addr_init(struct rocker_port *rocker_port)
 #define ROCKER_PORT_MAX_MTU	9000
 static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 {
-	const struct pci_dev *pdev = rocker->pdev;
+	struct pci_dev *pdev = rocker->pdev;
 	struct rocker_port *rocker_port;
 	struct net_device *dev;
 	int err;
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
