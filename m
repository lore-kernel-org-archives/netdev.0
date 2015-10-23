From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] macvtap: unbreak receiving of gro skb with frag list
Date: Fri, 23 Oct 2015 00:57:05 -0400
Message-ID: <1445576225-27710-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't have fraglist support in TAP_FEATURES. This will lead
software segmentation of gro skb with frag list. Fixes by having
frag list support in TAP_FEATURES.

With this patch single session of netperf receiving were restored from
about 5Gb/s to about 12Gb/s on mlx4.

Fixes a567dd6252 ("macvtap: simplify usage of tap_features")
Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 248478c..197c939 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -137,7 +137,7 @@ static const struct proto_ops macvtap_socket_ops;
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
 		      NETIF_F_TSO6 | NETIF_F_UFO)
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
-#define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
+#define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG | NETIF_F_FRAGLIST)
 
 static struct macvlan_dev *macvtap_get_vlan_rcu(const struct net_device *dev)
 {
-- 
1.8.3.1
