From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/6] can: enable CAN FD for virtual CAN devices by default
Date: Fri,  9 Jun 2017 14:55:13 +0200
Message-ID: <20170609125513.24436-7-mkl@pengutronix.de>
References: <20170609125513.24436-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48421 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751578AbdFIMzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 08:55:23 -0400
In-Reply-To: <20170609125513.24436-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

CAN FD capable CAN interfaces can handle (classic) CAN 2.0 frames too.
New users usually fail at their first attempt to explore CAN FD on
virtual CAN interfaces due to the current CAN_MTU default.

Set the MTU to CANFD_MTU by default to reduce this confusion.
If someone *really* needs a 'classic CAN'-only device this can be set
with the 'ip' tool with e.g. 'ip link set vcan0 mtu 16' as before.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/vcan.c  | 2 +-
 drivers/net/can/vxcan.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 0eda1b308583..a8cb33264ff1 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -152,7 +152,7 @@ static const struct net_device_ops vcan_netdev_ops = {
 static void vcan_setup(struct net_device *dev)
 {
 	dev->type		= ARPHRD_CAN;
-	dev->mtu		= CAN_MTU;
+	dev->mtu		= CANFD_MTU;
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->tx_queue_len	= 0;
diff --git a/drivers/net/can/vxcan.c b/drivers/net/can/vxcan.c
index 30cf2368becf..cfe889e8f172 100644
--- a/drivers/net/can/vxcan.c
+++ b/drivers/net/can/vxcan.c
@@ -150,7 +150,7 @@ static const struct net_device_ops vxcan_netdev_ops = {
 static void vxcan_setup(struct net_device *dev)
 {
 	dev->type		= ARPHRD_CAN;
-	dev->mtu		= CAN_MTU;
+	dev->mtu		= CANFD_MTU;
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->tx_queue_len	= 0;
-- 
2.11.0
