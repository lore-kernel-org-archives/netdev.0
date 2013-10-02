From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] netif_set_xps_queue: make cpu mask const
Date: Wed, 2 Oct 2013 09:14:06 +0300
Message-ID: <20131002061406.GA8809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Cong Wang <amwang@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>, rusty@rustcorp.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio wants to pass in cpumask_of(cpu), make parameter
const to avoid build warnings.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/netdevice.h | 5 +++--
 net/core/dev.c            | 3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3de49ac..25f5d2d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2264,11 +2264,12 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 }
 
 #ifdef CONFIG_XPS
-extern int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask,
+extern int netif_set_xps_queue(struct net_device *dev,
+			       const struct cpumask *mask,
 			       u16 index);
 #else
 static inline int netif_set_xps_queue(struct net_device *dev,
-				      struct cpumask *mask,
+				      const struct cpumask *mask,
 				      u16 index)
 {
 	return 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..f18eebd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1917,7 +1917,8 @@ static struct xps_map *expand_xps_map(struct xps_map *map,
 	return new_map;
 }
 
-int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask, u16 index)
+int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
+			u16 index)
 {
 	struct xps_dev_maps *dev_maps, *new_dev_maps = NULL;
 	struct xps_map *map, *new_map;
-- 
MST
