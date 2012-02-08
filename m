From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 43/50] macvlan: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:50 +0100
Message-ID: <1328735457-29986-44-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/macvlan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9ea9921..bc4614e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -373,6 +373,8 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 	if (!(dev->flags & IFF_UP)) {
 		/* Just copy in the new address */
 		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+		if (dev->addr_assign_type & NET_ADDR_RANDOM)
+			dev->addr_assign_type ^= NET_ADDR_RANDOM;
 	} else {
 		/* Rehash and update the device filters */
 		if (macvlan_addr_busy(vlan->port, addr->sa_data))
@@ -687,7 +689,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 
 	if (!tb[IFLA_ADDRESS])
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 
 	if (!macvlan_port_exists(lowerdev)) {
 		err = macvlan_port_create(lowerdev);
-- 
1.7.7.3
