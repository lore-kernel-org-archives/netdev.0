From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 24/31: x_tables: added hook number into match extension parameter structure.
Date: Wed, 10 Jun 2009 21:46:52 +0200 (MEST)
Message-ID: <20090610194650.11112.86094.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33201 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761107AbZFJTqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:50 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a5e78820966e17c2316866e00047e4e7e5480f04
Author: Evgeniy Polyakov <zbr@ioremap.net>
Date:   Thu Jun 4 16:54:42 2009 +0200

    netfilter: x_tables: added hook number into match extension parameter structure.
    
    Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index c9efe03..1030b75 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -184,9 +184,10 @@ struct xt_counters_info
  * @matchinfo:	per-match data
  * @fragoff:	packet is a fragment, this is the data offset
  * @thoff:	position of transport header relative to skb->data
- * @hotdrop:	drop packet if we had inspection problems
+ * @hook:	hook number given packet came from
  * @family:	Actual NFPROTO_* through which the function is invoked
  * 		(helpful when match->family == NFPROTO_UNSPEC)
+ * @hotdrop:	drop packet if we had inspection problems
  */
 struct xt_match_param {
 	const struct net_device *in, *out;
@@ -194,8 +195,9 @@ struct xt_match_param {
 	const void *matchinfo;
 	int fragoff;
 	unsigned int thoff;
-	bool *hotdrop;
+	unsigned int hooknum;
 	u_int8_t family;
+	bool *hotdrop;
 };
 
 /**
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 2455583..37928d5 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -170,7 +170,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	mtpar.in      = tgpar.in  = in;
 	mtpar.out     = tgpar.out = out;
 	mtpar.hotdrop = &hotdrop;
-	tgpar.hooknum = hook;
+	mtpar.hooknum = tgpar.hooknum = hook;
 
 	read_lock_bh(&table->lock);
 	private = table->private;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 7b35c0b..5bf7c3f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -343,7 +343,7 @@ ipt_do_table(struct sk_buff *skb,
 	mtpar.in      = tgpar.in  = in;
 	mtpar.out     = tgpar.out = out;
 	mtpar.family  = tgpar.family = NFPROTO_IPV4;
-	tgpar.hooknum = hook;
+	mtpar.hooknum = tgpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 	xt_info_rdlock_bh();
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 5164e0b..ced1f2c 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -369,7 +369,7 @@ ip6t_do_table(struct sk_buff *skb,
 	mtpar.in      = tgpar.in  = in;
 	mtpar.out     = tgpar.out = out;
 	mtpar.family  = tgpar.family = NFPROTO_IPV6;
-	tgpar.hooknum = hook;
+	mtpar.hooknum = tgpar.hooknum = hook;
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
