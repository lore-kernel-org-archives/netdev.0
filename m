From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 44/50] team: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:51 +0100
Message-ID: <1328735457-29986-45-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
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
 drivers/net/team/team.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6b678f3..b67ebc4 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -869,6 +869,9 @@ static int team_set_mac_address(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &team->port_list, list)
 		if (team->ops.port_change_mac)
@@ -1087,7 +1090,7 @@ static int team_newlink(struct net *src_net, struct net_device *dev,
 	int err;
 
 	if (tb[IFLA_ADDRESS] == NULL)
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 
 	err = register_netdevice(dev);
 	if (err)
-- 
1.7.7.3
