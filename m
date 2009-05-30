From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: unset IFF_XMIT_DST_RELEASE for qeth and ipoib
Date: Sat, 30 May 2009 11:02:32 +0200
Message-ID: <4A20F628.60002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60233 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbZE3JCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 05:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last two drivers that need skb->dst in their start_xmit() function

Tell dev_hard_start_xmit() to no release it by unsetting  IFF_XMIT_DST_RELEASE

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    1 +
 drivers/s390/net/qeth_l3_main.c           |    1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index ab2c192..69c6304 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1053,6 +1053,7 @@ static void ipoib_setup(struct net_device *dev)
 	dev->tx_queue_len	 = ipoib_sendq_size * 2;
 	dev->features		 = (NETIF_F_VLAN_CHALLENGED	|
 				    NETIF_F_HIGHDMA);
+	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 
 	memcpy(dev->broadcast, ipv4_bcast_addr, INFINIBAND_ALEN);
 
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index b36b5cd..cb64b0b 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3012,6 +3012,7 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 	card->dev->features |=	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |
 				NETIF_F_HW_VLAN_FILTER;
+	card->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	return register_netdev(card->dev);
