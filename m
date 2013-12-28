From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 19/20] net: plip: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:18:52 +0800
Message-ID: <52BE6D4C.5050307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal_64bits
to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/plip/plip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index 7b4ff35..040b897 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -547,9 +547,9 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
 	skb_pull(skb,dev->hard_header_len);
 	eth = eth_hdr(skb);
 
-	if(*eth->h_dest&1)
+	if(is_multicast_ether_addr(eth->h_dest))
 	{
-		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
+		if(ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
 			skb->pkt_type=PACKET_BROADCAST;
 		else
 			skb->pkt_type=PACKET_MULTICAST;
-- 
1.6.0.2
