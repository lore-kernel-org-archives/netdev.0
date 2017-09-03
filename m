From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 47/47] netfilter: rt: account for tcp header size too
Date: Mon,  4 Sep 2017 00:43:45 +0200
Message-ID: <1504478625-13330-2-git-send-email-pablo@netfilter.org>
References: <1504478625-13330-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53224 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753023AbdICWn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:43:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6ECE2190F66
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:43:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5E197B502C
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:43:31 +0200 (CEST)
In-Reply-To: <1504478625-13330-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This needs to accout for the ipv4/ipv6 header size and the tcp
header without options.

Fixes: 6b5dc98e8fac0 ("netfilter: rt: add support to fetch path mss")
Reported-by: Matteo Croce <technoboy85@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_rt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_rt.c b/net/netfilter/nft_rt.c
index 61fd3acaa3c9..a6b7d05aeacf 100644
--- a/net/netfilter/nft_rt.c
+++ b/net/netfilter/nft_rt.c
@@ -35,10 +35,11 @@ static u16 get_tcpmss(const struct nft_pktinfo *pkt, const struct dst_entry *skb
 	switch (nft_pf(pkt)) {
 	case NFPROTO_IPV4:
 		fl.u.ip4.daddr = ip_hdr(skb)->saddr;
-		minlen = sizeof(struct iphdr);
+		minlen = sizeof(struct iphdr) + sizeof(struct tcphdr);
 		break;
 	case NFPROTO_IPV6:
 		fl.u.ip6.daddr = ipv6_hdr(skb)->saddr;
+		minlen = sizeof(struct ipv6hdr) + sizeof(struct tcphdr);
 		break;
 	}
 
-- 
2.1.4
