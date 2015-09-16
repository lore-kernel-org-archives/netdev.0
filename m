From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 20/30] ipv6: Don't recompute net in ip6_rcv
Date: Tue, 15 Sep 2015 20:04:08 -0500
Message-ID: <1442365458-16349-20-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid silly redundant code

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/ip6_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index adba03ac7ce9..c628dba477d4 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -109,7 +109,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (hdr->version != 6)
 		goto err;
 
-	IP6_ADD_STATS_BH(dev_net(dev), idev,
+	IP6_ADD_STATS_BH(net, idev,
 			 IPSTATS_MIB_NOECTPKTS +
 				(ipv6_get_dsfield(hdr) & INET_ECN_MASK),
 			 max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
-- 
2.2.1

