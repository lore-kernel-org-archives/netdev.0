From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/7] 8021q: Use ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:14 -0800
Message-ID: <d925be29591181e70c54abb79d514c87ac8feb06.1390239869.git.joe@perches.com>
References: <cover.1390239869.git.joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1390239869.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ether_addr_copy instead of memcpy(a, b, ETH_ALEN) to
save some cycles on arm and powerpc.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlan.c     | 2 +-
 net/8021q/vlan_dev.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b3d17d1..ec99099 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -301,7 +301,7 @@ static void vlan_sync_address(struct net_device *dev,
 	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
 		dev_uc_add(dev, vlandev->dev_addr);
 
-	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
 }
 
 static void vlan_transfer_features(struct net_device *dev,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 47c908f..de51c48 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -61,7 +61,7 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 		pr_debug("%s: unable to resolve type %X addresses\n",
 			 dev->name, ntohs(veth->h_vlan_encapsulated_proto));
 
-		memcpy(veth->h_source, dev->dev_addr, ETH_ALEN);
+		ether_addr_copy(veth->h_source, dev->dev_addr);
 		break;
 	}
 
@@ -303,7 +303,7 @@ static int vlan_dev_open(struct net_device *dev)
 			goto clear_allmulti;
 	}
 
-	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
+	ether_addr_copy(vlan->real_dev_addr, real_dev->dev_addr);
 
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_join(dev);
@@ -367,7 +367,7 @@ static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 		dev_uc_del(real_dev, dev->dev_addr);
 
 out:
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	ether_addr_copy(dev->dev_addr, addr->sa_data);
 	return 0;
 }
 
-- 
1.8.1.2.459.gbcd45b4.dirty
