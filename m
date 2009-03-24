From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 16/41: fix hardcoded size assumptions
Date: Tue, 24 Mar 2009 15:03:28 +0100 (MET)
Message-ID: <20090324140324.31401.4625.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34780 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758177AbZCXODb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:31 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit af07d241dc76f0a52c7ff04df3a3970020fe6157
Author: Hagen Paul Pfeifer <hagen@jauu.net>
Date:   Fri Feb 20 10:48:06 2009 +0100

    netfilter: fix hardcoded size assumptions
    
    get_random_bytes() is sometimes called with a hard coded size assumption
    of an integer. This could not be true for next centuries. This patch
    replace it with a compile time statement.
    
    Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f3aa4e6..2235432 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -472,7 +472,8 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	struct nf_conn *ct;
 
 	if (unlikely(!nf_conntrack_hash_rnd_initted)) {
-		get_random_bytes(&nf_conntrack_hash_rnd, 4);
+		get_random_bytes(&nf_conntrack_hash_rnd,
+				sizeof(nf_conntrack_hash_rnd));
 		nf_conntrack_hash_rnd_initted = 1;
 	}
 
@@ -1103,7 +1104,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 
 	/* We have to rehahs for the new table anyway, so we also can
 	 * use a newrandom seed */
-	get_random_bytes(&rnd, 4);
+	get_random_bytes(&rnd, sizeof(rnd));
 
 	/* Lookups in the old hash might happen in parallel, which means we
 	 * might get false negatives during connection lookup. New connections
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 3a8a34a..357ba39 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -72,7 +72,8 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 	unsigned int hash;
 
 	if (unlikely(!nf_ct_expect_hash_rnd_initted)) {
-		get_random_bytes(&nf_ct_expect_hash_rnd, 4);
+		get_random_bytes(&nf_ct_expect_hash_rnd,
+				 sizeof(nf_ct_expect_hash_rnd));
 		nf_ct_expect_hash_rnd_initted = 1;
 	}
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index f97fded..2482055 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -149,7 +149,7 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	/* initialize hash with random val at the time we allocate
 	 * the first hashtable entry */
 	if (!ht->rnd_initialized) {
-		get_random_bytes(&ht->rnd, 4);
+		get_random_bytes(&ht->rnd, sizeof(ht->rnd));
 		ht->rnd_initialized = 1;
 	}
 
