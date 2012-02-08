From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 39/50] veth: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:46 +0100
Message-ID: <1328735457-29986-40-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Rick Jones <rick.jones2@hp.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/veth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 49f4667..1dd466a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -346,7 +346,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	}
 
 	if (tbp[IFLA_ADDRESS] == NULL)
-		random_ether_addr(peer->dev_addr);
+		dev_hw_addr_random(peer, peer->dev_addr);
 
 	err = register_netdevice(peer);
 	put_net(net);
@@ -368,7 +368,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	 */
 
 	if (tb[IFLA_ADDRESS] == NULL)
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 
 	if (tb[IFLA_IFNAME])
 		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);
-- 
1.7.7.3
