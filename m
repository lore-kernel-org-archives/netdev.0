From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 35/50] ifb: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:42 +0100
Message-ID: <1328735457-29986-36-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:34257 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932196Ab2BHVVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 16:21:48 -0500
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ifb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index e05b645..9ec2a86 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -184,7 +184,7 @@ static void ifb_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
-	random_ether_addr(dev->dev_addr);
+	dev_hw_addr_random(dev, dev->dev_addr);
 }
 
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.7.7.3
