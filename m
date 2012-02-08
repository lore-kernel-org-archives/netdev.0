From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 06/50] dummy: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:13 +0100
Message-ID: <1328735457-29986-7-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>
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
 drivers/net/dummy.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 087648e..a766598 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -48,6 +48,8 @@ static int dummy_set_address(struct net_device *dev, void *p)
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
 	return 0;
 }
 
@@ -135,7 +137,7 @@ static void dummy_setup(struct net_device *dev)
 	dev->flags &= ~IFF_MULTICAST;
 	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
 	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
-	random_ether_addr(dev->dev_addr);
+	dev_hw_addr_random(dev, dev->dev_addr);
 }
 
 static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.7.7.3
