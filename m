From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] macvlan: delay the header check for dodgy packets into lower device
Date: Wed, 26 Nov 2014 17:21:14 +0800
Message-ID: <1416993674-11177-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, vyasevic@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We do header check twice for a dodgy packet. One is done before
macvlan_start_xmit(), another is done before lower device's
ndo_start_xmit(). The first one seems redundant so this patch tries to
delay header check until a packet reaches its lower device (or macvtap)
through always enabling NETIF_F_GSO_ROBUST for macvlan device.

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvlan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index bfb0b6e..11d4b35 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -742,11 +742,12 @@ static struct lock_class_key macvlan_netdev_xmit_lock_key;
 static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define ALWAYS_ON_FEATURES \
-	(NETIF_F_SG | NETIF_F_GEN_CSUM | NETIF_F_GSO_SOFTWARE | NETIF_F_LLTX)
+	(NETIF_F_SG | NETIF_F_GEN_CSUM | NETIF_F_GSO_SOFTWARE | NETIF_F_LLTX | \
+	 NETIF_F_GSO_ROBUST)
 
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
-	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
+	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
 
-- 
1.9.1
