From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 2/2] netfilter: fix hardcoded size assumptions
Date: Fri, 20 Feb 2009 00:43:42 +0100
Message-ID: <1235087023-30451-3-git-send-email-hagen@jauu.net>
References: <1235087023-30451-1-git-send-email-hagen@jauu.net>
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39701 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754919AbZBTABX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 19:01:23 -0500
In-Reply-To: <1235087023-30451-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_random_bytes() is sometimes called with a hard coded size assumption
of an integer. This could not be true for next centuries. This patch
replace it with a compile time statement.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/netfilter/nf_conntrack_core.c   |    5 +++--
 net/netfilter/nf_conntrack_expect.c |    2 +-
 net/netfilter/xt_hashlimit.c        |    2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

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
index 3a8a34a..19b4779 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -72,7 +72,7 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 	unsigned int hash;
 
 	if (unlikely(!nf_ct_expect_hash_rnd_initted)) {
-		get_random_bytes(&nf_ct_expect_hash_rnd, 4);
+		get_random_bytes(&nf_ct_expect_hash_rnd, sizeof(nf_ct_expect_hash_rnd));
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
 
-- 
1.5.6.5

