From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 1/6] inet: frags: use INC_STATS_BH in the ipv6 reassembly code
Date: Fri,  1 Aug 2014 12:29:43 +0200
Message-ID: <1406888988-20742-2-git-send-email-nikolay@redhat.com>
References: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515AbaHAKav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 06:30:51 -0400
In-Reply-To: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Softirqs are already disabled so no need to do it again, thus let's be
consistent and use the IP6_INC_STATS_BH variant.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2: no changes

 net/ipv6/reassembly.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index f1709c4a289a..512ccc027ce3 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -355,8 +355,8 @@ found:
 discard_fq:
 	inet_frag_kill(&fq->q, &ip6_frags);
 err:
-	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-		      IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
+			 IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 }
@@ -566,7 +566,8 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	return -1;
 
 fail_hdr:
-	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
+			 IPSTATS_MIB_INHDRERRORS);
 	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb_network_header_len(skb));
 	return -1;
 }
-- 
1.9.3
