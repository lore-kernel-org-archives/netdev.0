From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 4/4] dummy: use IFF_LIFE_ADDR_CHANGE priv_flag
Date: Thu, 28 Jun 2012 16:10:39 +0200
Message-ID: <1340892639-1111-5-git-send-email-jpirko@redhat.com>
References: <1340892639-1111-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	danny.kukawka@bisect.de, shimoda.hiroaki@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754028Ab2F1OKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2012 10:10:55 -0400
In-Reply-To: <1340892639-1111-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/dummy.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index bab0158..0352246 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -40,18 +40,6 @@
 
 static int numdummies = 1;
 
-static int dummy_set_address(struct net_device *dev, void *p)
-{
-	struct sockaddr *sa = p;
-
-	if (!is_valid_ether_addr(sa->sa_data))
-		return -EADDRNOTAVAIL;
-
-	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
-	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
-	return 0;
-}
-
 /* fake multicast ability */
 static void set_multicast_list(struct net_device *dev)
 {
@@ -118,7 +106,7 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_start_xmit		= dummy_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= set_multicast_list,
-	.ndo_set_mac_address	= dummy_set_address,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_get_stats64	= dummy_get_stats64,
 };
 
@@ -134,6 +122,7 @@ static void dummy_setup(struct net_device *dev)
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
+	dev->priv_flags |= IFF_LIFE_ADDR_CHANGE;
 	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
 	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
 	eth_hw_addr_random(dev);
-- 
1.7.10.4
