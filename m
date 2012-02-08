From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 32/50] tile_net: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:39 +0100
Message-ID: <1328735457-29986-33-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>
To: "David S. Miller" <davem@davemloft.net>
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
 drivers/net/ethernet/tile/tilepro.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index d9951af..f007df4 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2190,6 +2190,8 @@ static int tile_net_set_mac_address(struct net_device *dev, void *p)
 
 	/* ISSUE: Note that "dev_addr" is now a pointer. */
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
 
 	return 0;
 }
@@ -2254,7 +2256,7 @@ static int tile_net_get_mac(struct net_device *dev)
 		 * can't get its MAC address, we are most likely running
 		 * the simulator, so let's generate a random MAC address.
 		 */
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 	}
 
 	return 0;
-- 
1.7.7.3
