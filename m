From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: nf_tables: only allow in/output for arp packets
Date: Tue, 18 Jul 2017 12:13:58 +0200
Message-ID: <1500372839-6735-5-git-send-email-pablo@netfilter.org>
References: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

arp packets cannot be forwarded.

They can be bridged, but then they can be filtered using
either ebtables or nftables bridge family.

The bridge netfilter exposes a "call-arptables" switch which
pushes packets into arptables, but lets not expose this for nftables, so better
close this asap.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_tables_arp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 805c8ddfe860..4bbc273b45e8 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -72,8 +72,7 @@ static const struct nf_chain_type filter_arp = {
 	.family		= NFPROTO_ARP,
 	.owner		= THIS_MODULE,
 	.hook_mask	= (1 << NF_ARP_IN) |
-			  (1 << NF_ARP_OUT) |
-			  (1 << NF_ARP_FORWARD),
+			  (1 << NF_ARP_OUT),
 };
 
 static int __init nf_tables_arp_init(void)
-- 
2.1.4

