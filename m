From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv2 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Fri, 12 Sep 2014 19:18:49 -0400
Message-ID: <54137F59.4040904@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18839 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaILXSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 19:18:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows an admin to set the MTU on a sunvnet device to arbitrary
values between the minimum (68) and maximum (65535) IPv4 packet sizes.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    6 +++++-
 drivers/net/ethernet/sun/sunvnet.h |    2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index a6418bb..b557ec4 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -751,6 +751,10 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!port))
 		goto out_dropped;

+	if (skb->len > port->vio.rmtu) {
+		goto out_dropped;
+	}
+
 	spin_lock_irqsave(&port->vio.lock, flags);

 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
@@ -972,7 +976,7 @@ static void vnet_set_rx_mode(struct net_device *dev)

 static int vnet_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu != ETH_DATA_LEN)
+	if (new_mtu < 68 || new_mtu > 65535)
 		return -EINVAL;

 	dev->mtu = new_mtu;
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index 243ae69..fcf0129 100644
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
