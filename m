From: pablo@netfilter.org
Subject: [PATCH 15/19] netfilter: nf_nat: remove obsolete check in nf_nat_mangle_udp_packet()
Date: Sun, 25 Dec 2011 02:57:31 +0100
Message-ID: <1324778255-2830-16-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The packet size check originates from a time when UDP helpers could
accidentally mangle incorrect packets (NEWNAT) and is unnecessary
nowadays since the conntrack helpers invoke the NAT helpers for the
proper packet directly.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_helper.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 049e8b7..af65958 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -253,12 +253,6 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 	struct udphdr *udph;
 	int datalen, oldlen;
 
-	/* UDP helpers might accidentally mangle the wrong packet */
-	iph = ip_hdr(skb);
-	if (skb->len < iph->ihl*4 + sizeof(*udph) +
-			       match_offset + match_len)
-		return 0;
-
 	if (!skb_make_writable(skb, skb->len))
 		return 0;
 
-- 
1.7.2.5

