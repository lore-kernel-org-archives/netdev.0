From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next] bridge: Set vlan_features to allow
	offloads on vlans.
Date: Wed, 22 May 2013 13:49:34 -0400
Message-ID: <1369244974-10160-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

When vlan device is configured on top of the brige, it does
not support any offload capabilities because the bridge
device does not initiliaze vlan_fatures.  Set vlan_fatures to
be equivalent to hw_fatures.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 9673128..75f3239 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -22,6 +22,9 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
+#define COMMON_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA | \
+			 NETIF_F_GSO_MASK | NETIF_F_HW_CSUM)
+
 /* net device transmit always called with BH disabled */
 netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -346,12 +349,10 @@ void br_dev_setup(struct net_device *dev)
 	dev->tx_queue_len = 0;
 	dev->priv_flags = IFF_EBRIDGE;
 
-	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
-			NETIF_F_GSO_MASK | NETIF_F_HW_CSUM | NETIF_F_LLTX |
-			NETIF_F_NETNS_LOCAL | NETIF_F_HW_VLAN_CTAG_TX;
-	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
-			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
-			   NETIF_F_HW_VLAN_CTAG_TX;
+	dev->features = COMMON_FEATURES | NETIF_F_LLTX | NETIF_F_NETNS_LOCAL |
+			NETIF_F_HW_VLAN_CTAG_TX;
+	dev->hw_features = COMMON_FEATURES | NETIF_F_HW_VLAN_CTAG_TX;
+	dev->vlan_features = COMMON_FEATURES;
 
 	br->dev = dev;
 	spin_lock_init(&br->lock);
-- 
1.7.7.6
