From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ifb: support more features
Date: Fri, 06 May 2016 16:41:16 -0700
Message-ID: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32781 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758804AbcEFXlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 19:41:19 -0400
Received: by mail-pf0-f170.google.com with SMTP id 206so54810060pfu.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 16:41:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When using ifb+netem on ingress on SIT/IPIP/GRE traffic,
GRO packets are not properly processed.

Segmentation should not be forced, as ifb is already adding
quite a performance hit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ifb.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index cc56fac3c3f8..0cb5d8cbe679 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -197,7 +197,7 @@ static const struct net_device_ops ifb_netdev_ops = {
 #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
 		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
 		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX		| \
-		      NETIF_F_HW_VLAN_STAG_TX)
+		      NETIF_F_GSO_ENCAP_ALL | NETIF_F_HW_VLAN_STAG_TX)
 
 static void ifb_dev_free(struct net_device *dev)
 {
@@ -224,6 +224,7 @@ static void ifb_setup(struct net_device *dev)
 	dev->tx_queue_len = TX_Q_LIMIT;
 
 	dev->features |= IFB_FEATURES;
+	dev->hw_features |= NETIF_F_GSO_ENCAP_ALL;
 	dev->vlan_features |= IFB_FEATURES & ~(NETIF_F_HW_VLAN_CTAG_TX |
 					       NETIF_F_HW_VLAN_STAG_TX);
 
