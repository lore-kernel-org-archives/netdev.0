From: kaber@trash.net
Subject: [PATCH 01/17] netfilter: nf_nat: use hash random for bysource hash
Date: Mon, 21 Nov 2011 06:45:53 +0100
Message-ID: <1321854369-3432-2-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61044 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab1KUFqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:46:14 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Use nf_conntrack_hash_rnd in NAT bysource hash to avoid hash chain attacks.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_core.c  |    2 +-
 net/netfilter/nf_conntrack_core.c |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 3346de5..ffb0c94 100644
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
index f7af8b8..df12969 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -67,6 +67,7 @@ DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
 unsigned int nf_conntrack_hash_rnd __read_mostly;
+EXPORT_SYMBOL_GPL(nf_conntrack_hash_rnd);
 
 static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
 {
-- 
1.7.1
