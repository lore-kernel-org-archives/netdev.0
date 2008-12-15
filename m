From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-next] vcan: convert to net_device_ops
Date: Mon, 15 Dec 2008 21:54:49 +0100
Message-ID: <4946C419.7040404@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010800030305010501040802"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:32067 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbYLOUyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 15:54:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010800030305010501040802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

vcan: convert to net_device_ops

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
CC: Stephen Hemminger <shemminger@vyatta.com>
---

This patch converts the virtual CAN driver vcan to use net_device_ops.
It's functionally tested.

Regards,
Oliver



--------------010800030305010501040802
Content-Type: text/x-patch;
 name="vcan_netdev_ops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vcan_netdev_ops.patch"

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 103f0f1..f127ec9 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -128,6 +128,10 @@ static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static const struct net_device_ops vcan_netdev_ops = {
+	.ndo_start_xmit = vcan_tx,
+};
+
 static void vcan_setup(struct net_device *dev)
 {
 	dev->type              = ARPHRD_CAN;
@@ -141,7 +145,7 @@ static void vcan_setup(struct net_device *dev)
 	if (echo)
 		dev->flags |= IFF_ECHO;
 
-	dev->hard_start_xmit   = vcan_tx;
+	dev->netdev_ops        = &vcan_netdev_ops;
 	dev->destructor        = free_netdev;
 }
 

--------------010800030305010501040802--
