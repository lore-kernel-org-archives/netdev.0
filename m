From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] udp: remove else after return
Date: Tue,  4 Nov 2014 20:48:41 +0100
Message-ID: <1415130521-16479-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

else is unnecessary after return 0 in __udp4_lib_rcv()

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/udp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db54..cf0cece 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1777,14 +1777,14 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		if (ret > 0)
 			return -ret;
 		return 0;
-	} else {
-		if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-			return __udp4_lib_mcast_deliver(net, skb, uh,
-					saddr, daddr, udptable);
-
-		sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 	}
 
+	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
+		return __udp4_lib_mcast_deliver(net, skb, uh,
+				saddr, daddr, udptable);
+
+	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
+
 	if (sk != NULL) {
 		int ret;
 
-- 
1.9.3
