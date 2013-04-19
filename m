From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 6/6] net: vlan: announce STAG offload capability in some drivers
Date: Fri, 19 Apr 2013 14:04:32 +0200
Message-ID: <1366373072-19621-7-git-send-email-kaber@trash.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46105 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030221Ab3DSMEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:04:42 -0400
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- macvlan: propagate STAG filtering capabilities from underlying device
- ifb: announce STAG tagging support in addition to CTAG tagging support
- veth: announce STAG tagging/stripping support in addition to CTAG support

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/net/ifb.c     | 3 ++-
 drivers/net/macvlan.c | 2 +-
 drivers/net/veth.c    | 3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 724ce7a..dc9f6a4 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -166,7 +166,8 @@ static const struct net_device_ops ifb_netdev_ops = {
 
 #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
 		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
-		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX)
+		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX		| \
+		      NETIF_F_HW_VLAN_STAG_TX)
 
 static void ifb_setup(struct net_device *dev)
 {
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 7347cdb..d5a141c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -471,7 +471,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
-	 NETIF_F_HW_VLAN_CTAG_FILTER)
+	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
 
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f116c59..177f911 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -255,7 +255,8 @@ static const struct net_device_ops veth_netdev_ops = {
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
 		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
-		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX)
+		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
+		       NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )
 
 static void veth_setup(struct net_device *dev)
 {
-- 
1.8.1.4
