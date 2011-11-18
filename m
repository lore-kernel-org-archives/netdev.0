From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/6] ip_gre: Set needed_headroom dynamically again
Date: Fri, 18 Nov 2011 20:20:06 +0800
Message-ID: <E1RRNQM-0000ls-CP@gondolin.me.apana.org.au>
References: <20111118121832.GA2868@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	evonlanthen@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, timo.teras@iki.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_gre: Set needed_headroom dynamically again

Now that all needed_headroom users have been fixed up so that
we can safely increase needed_headroom, this patch restore the
dynamic update of needed_headroom.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ip_gre.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d55110e..d7bb94c 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -835,6 +835,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
+		if (max_headroom > dev->needed_headroom)
+			dev->needed_headroom = max_headroom;
 		if (!new_skb) {
 			ip_rt_put(rt);
 			dev->stats.tx_dropped++;
