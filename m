From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv4 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Mon, 15 Sep 2014 20:35:36 -0400
Message-ID: <541785D8.5030101@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26844 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933169AbaIPAfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 20:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows an admin to set the MTU on a sunvnet device to arbitrary
values between the minimum (68) and maximum (65535) IPv4 packet sizes.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    5 ++++-
 drivers/net/ethernet/sun/sunvnet.h |    2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index a9638c1..5619798 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -791,6 +791,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!port))
 		goto out_dropped;
 
+	if (skb->len > port->rmtu)
+		goto out_dropped;
+
 	spin_lock_irqsave(&port->vio.lock, flags);
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
@@ -1038,7 +1041,7 @@ static void vnet_set_rx_mode(struct net_device *dev)
 
 static int vnet_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu != ETH_DATA_LEN)
+	if (new_mtu < 68 || new_mtu > 65535)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index 986e04b..809b122 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -11,7 +11,7 @@
  */
 #define VNET_TX_TIMEOUT			(5 * HZ)
 
-#define VNET_MAXPACKET			1518ULL /* ETH_FRAMELEN + VLAN_HDR */
+#define VNET_MAXPACKET			65553ULL /* 64K-1  +ETH HDR +VLAN HDR*/
 #define VNET_TX_RING_SIZE		512
 #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)
 
-- 
1.7.1
