From: Dimitris Michailidis <dmichail@google.com>
Subject: [PATCH net-next] macvlan: add offload features for encapsulation
Date: Wed, 16 Aug 2017 14:34:46 -0700
Message-ID: <20170816213446.10584-1-dmichail@google.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:37144 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752382AbdHPVev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:34:51 -0400
Received: by mail-pg0-f52.google.com with SMTP id y129so29056310pgy.4
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 14:34:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently macvlan devices do not set their hw_enc_features making
encapsulated Tx packets resort to SW fallbacks. Add encapsulation GSO
offloads to ->features as is done for the other GSOs and set
->hw_enc_features.

Signed-off-by: Dimitris Michailidis <dmichail@google.com>
---
 drivers/net/macvlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index ca35c6ba7947..d2aea961e0f4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -835,7 +835,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define ALWAYS_ON_OFFLOADS \
 	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE | \
-	 NETIF_F_GSO_ROBUST)
+	 NETIF_F_GSO_ROBUST | NETIF_F_GSO_ENCAP_ALL)
 
 #define ALWAYS_ON_FEATURES (ALWAYS_ON_OFFLOADS | NETIF_F_LLTX)
 
@@ -874,6 +874,7 @@ static int macvlan_init(struct net_device *dev)
 	dev->hw_features	|= NETIF_F_LRO;
 	dev->vlan_features	= lowerdev->vlan_features & MACVLAN_FEATURES;
 	dev->vlan_features	|= ALWAYS_ON_OFFLOADS;
+	dev->hw_enc_features    |= dev->features;
 	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->gso_max_segs	= lowerdev->gso_max_segs;
 	dev->hard_header_len	= lowerdev->hard_header_len;
-- 
2.14.1.480.gb18f417b89-goog
