From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] vlan: propagate gso_min_segs
Date: Wed, 23 Mar 2016 09:35:14 +0800
Message-ID: <1458696914-16088-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vlan drivers lack proper propagation of gso_min_segs from lower device.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 2 ++
 drivers/net/macvlan.c            | 1 +
 net/8021q/vlan.c                 | 1 +
 net/8021q/vlan_dev.c             | 1 +
 4 files changed, 5 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 57941d3..72a2517 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -120,6 +120,7 @@ static int ipvlan_init(struct net_device *dev)
 	dev->features |= NETIF_F_LLTX;
 	dev->gso_max_size = phy_dev->gso_max_size;
 	dev->gso_max_segs = phy_dev->gso_max_segs;
+	dev->gso_min_segs = phy_dev->gso_min_segs;
 	dev->hard_header_len = phy_dev->hard_header_len;
 
 	ipvlan_set_lockdep_class(dev);
@@ -594,6 +595,7 @@ static int ipvlan_device_event(struct notifier_block *unused,
 			ipvlan->dev->features = dev->features & IPVLAN_FEATURES;
 			ipvlan->dev->gso_max_size = dev->gso_max_size;
 			ipvlan->dev->gso_max_segs = dev->gso_max_segs;
+			ipvlan->dev->gso_min_segs = dev->gso_min_segs;
 			netdev_features_change(ipvlan->dev);
 		}
 		break;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2bcf1f3..72991e9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1534,6 +1534,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 		list_for_each_entry(vlan, &port->vlans, list) {
 			vlan->dev->gso_max_size = dev->gso_max_size;
 			vlan->dev->gso_max_segs = dev->gso_max_segs;
+			vlan->dev->gso_min_segs = dev->gso_min_segs;
 			netdev_update_features(vlan->dev);
 		}
 		break;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index a1e273a..01a4de1 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -312,6 +312,7 @@ static void vlan_transfer_features(struct net_device *dev,
 
 	vlandev->gso_max_size = dev->gso_max_size;
 	vlandev->gso_max_segs = dev->gso_max_segs;
+	vlandev->gso_min_segs = dev->gso_min_segs;
 
 	if (vlan_hw_offload_capable(dev->features, vlan->vlan_proto))
 		vlandev->hard_header_len = dev->hard_header_len;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index e7e6257..752263d 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -552,6 +552,7 @@ static int vlan_dev_init(struct net_device *dev)
 			 NETIF_F_GSO_SOFTWARE;
 	dev->gso_max_size = real_dev->gso_max_size;
 	dev->gso_max_segs = real_dev->gso_max_segs;
+	dev->gso_min_segs = real_dev->gso_min_segs;
 	if (dev->features & NETIF_F_VLAN_FEATURES)
 		netdev_warn(real_dev, "VLAN features are set incorrectly.  Q-in-Q configurations may not work correctly.\n");
 
-- 
1.8.3.1
