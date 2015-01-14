From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/8] netfilter: conntrack: Remove nf_ct_conntrack_flush_report
Date: Wed, 14 Jan 2015 21:34:49 +0100
Message-ID: <1421267689-24894-9-git-send-email-pablo@netfilter.org>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49671 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115AbbANUcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 15:32:07 -0500
In-Reply-To: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>

The only user of nf_ct_conntrack_flush_report() was ctnetlink_del_conntrack().
After adding support for flushing connections with a given mark, this function
is no longer called.

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |    2 --
 net/netfilter/nf_conntrack_core.c    |    6 ------
 2 files changed, 8 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index f0daed2..74f271a 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -191,8 +191,6 @@ __nf_conntrack_find(struct net *net, u16 zone,
 int nf_conntrack_hash_check_insert(struct nf_conn *ct);
 bool nf_ct_delete(struct nf_conn *ct, u32 pid, int report);
 
-void nf_conntrack_flush_report(struct net *net, u32 portid, int report);
-
 bool nf_ct_get_tuplepr(const struct sk_buff *skb, unsigned int nhoff,
 		       u_int16_t l3num, struct nf_conntrack_tuple *tuple);
 bool nf_ct_invert_tuplepr(struct nf_conntrack_tuple *inverse,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index da58cd4..5a6990b 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1426,12 +1426,6 @@ void nf_ct_free_hashtable(void *hash, unsigned int size)
 }
 EXPORT_SYMBOL_GPL(nf_ct_free_hashtable);
 
-void nf_conntrack_flush_report(struct net *net, u32 portid, int report)
-{
-	nf_ct_iterate_cleanup(net, kill_all, NULL, portid, report);
-}
-EXPORT_SYMBOL_GPL(nf_conntrack_flush_report);
-
 static int untrack_refs(void)
 {
 	int cnt = 0, cpu;
-- 
1.7.10.4
