From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH 1/6] net/bonding: enable LRO if one device supports it
Date: Thu, 13 Aug 2015 14:02:55 -0400
Message-ID: <1439488980-44738-2-git-send-email-jarod@redhat.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Tom Herbert <therbert@google.com>,
	Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, all bonding devices come up, and claim to have LRO support,
which ethtool will let you toggle on and off, even if none of the
underlying hardware devices actually support it. While the bonding driver
takes precautions for slaves that don't support all features, this is at
least a little bit misleading to users.

If we add NETIF_F_LRO to the NETIF_F_ONE_FOR_ALL flags in
netdev_features.h, then netdev_features_increment() will only enable LRO
if 1) its listed in the device's feature mask and 2) if there's actually a
slave present that supports the feature.

Note that this is going to require some follow-up patches, as not all LRO
capable device drivers are currently properly reporting LRO support in
their vlan_features, which is where the bonding driver picks up
device-specific features.

CC: "David S. Miller" <davem@davemloft.net>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Tom Herbert <therbert@google.com>
CC: Scott Feldman <sfeldma@gmail.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 include/linux/netdev_features.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9672781..6440bf1 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -159,7 +159,8 @@ enum {
  */
 #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
-				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
+				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED | \
+				 NETIF_F_LRO)
 
 /*
  * If one device doesn't support one of these features, then disable it
-- 
1.8.3.1
