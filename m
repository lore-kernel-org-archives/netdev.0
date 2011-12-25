From: pablo@netfilter.org
Subject: [PATCH 11/19] netfilter: nf_nat: use hash random for bysource hash
Date: Sun, 25 Dec 2011 02:57:27 +0100
Message-ID: <1324778255-2830-12-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Use nf_conntrack_hash_rnd in NAT bysource hash to avoid hash chain attacks.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_nat_core.c  |    2 +-
 net/netfilter/nf_conntrack_core.c |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 58ab7a4..76600f8 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -57,7 +57,7 @@ hash_by_src(const struct net *net, u16 zone,
 	/* Original src, to ensure we map it consistently if poss. */
 	hash = jhash_3words((__force u32)tuple->src.u3.ip,
 			    (__force u32)tuple->src.u.all ^ zone,
-			    tuple->dst.protonum, 0);
+			    tuple->dst.protonum, nf_conntrack_hash_rnd);
 	return ((u64)hash * net->ipv4.nat_htable_size) >> 32;
 }
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 8b2842e..b76090f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -67,6 +67,7 @@ DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
 unsigned int nf_conntrack_hash_rnd __read_mostly;
+EXPORT_SYMBOL_GPL(nf_conntrack_hash_rnd);
 
 static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
 {
-- 
1.7.2.5

