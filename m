From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 11/14] ethernet: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:56 -0800
Message-ID: <01fdfdeae449c5164143d3b094075e38f8302429.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ethernet/eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 8dbdf6c..f3bad41 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -104,7 +104,7 @@ int eth_header(struct sk_buff *skb, struct net_device *dev,
 	 */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		memset(eth->h_dest, 0, ETH_ALEN);
+		eth_zero_addr(eth->h_dest);
 		return ETH_HLEN;
 	}
 
@@ -357,7 +357,7 @@ void ether_setup(struct net_device *dev)
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
 	dev->priv_flags		|= IFF_TX_SKB_SHARING;
 
-	memset(dev->broadcast, 0xFF, ETH_ALEN);
+	eth_broadcast_addr(dev->broadcast);
 
 }
 EXPORT_SYMBOL(ether_setup);
-- 
2.1.2
