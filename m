From: Philipp Kern <pkern@debian.org>
Subject: [PATCH] net: move "IPv6: sending pkt_too_big to self" to NETDEBUG
Date: Sat, 28 Jul 2012 17:06:37 +0200
Message-ID: <1343487997-9047-1-git-send-email-pkern@debian.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	ak@linux.intel.com, Philipp Kern <pkern@debian.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip6_xmit checks if the outgoing packet is larger than the path MTU and
emits ICMPv6 packet too big locally if this is the case. Logging this,
even at KERN_DEBUG, confuses users. It is also not actually helpful for
debugging, given that there is no reference to the connection that
triggered this event.

Hence move this message to LIMIT_NETDEBUG, as suggested by Andi Kleen
back in 2001 (<20010215231715.26269@colin.muc.de>).

Signed-off-by: Philipp Kern <pkern@debian.org>
---
 net/ipv6/ip6_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5b2d63e..707002f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -241,7 +241,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 			       dst->dev, dst_output);
 	}
 
-	net_dbg_ratelimited("IPv6: sending pkt_too_big to self\n");
+	LIMIT_NETDEBUG("IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_FRAGFAILS);
-- 
1.7.10.4
