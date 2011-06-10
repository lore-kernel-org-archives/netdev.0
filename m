From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Enable NETIF_F_TSO6 for VLAN traffic for BE
Date: Fri, 10 Jun 2011 16:31:48 +0530
Message-ID: <5c1f3a19-f30f-40b4-8715-86348d7917c5@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:12888 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753428Ab1FJLCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 07:02:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_TSO6 for VLAN packets was not enabled for BE adapters.
Enabling it.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9ba197b..6ddaa34 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2925,12 +2925,9 @@ static void be_netdev_init(struct net_device *netdev)
 	netdev->features |= netdev->hw_features |
 		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 
-	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO |
+	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 
-	if (lancer_chip(adapter))
-		netdev->vlan_features |= NETIF_F_TSO6;
-
 	netdev->flags |= IFF_MULTICAST;
 
 	/* Default settings for Rx and Tx flow control */
-- 
1.6.0.2

