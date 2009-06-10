From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 17/31: ctnetlink: rename tuple() by nf_ct_tuple() macro definition
Date: Wed, 10 Jun 2009 21:46:43 +0200 (MEST)
Message-ID: <20090610194641.11112.48537.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33181 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761125AbZFJTql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:41 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f2f3e38c63c58a3d39bd710039af8bbd15ecaff6
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Jun 2 20:03:35 2009 +0200

    netfilter: ctnetlink: rename tuple() by nf_ct_tuple() macro definition
    
    This patch move the internal tuple() macro definition to the
    header file as nf_ct_tuple().
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 6c3f964..b909241 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -144,6 +144,8 @@ static inline u_int8_t nf_ct_protonum(const struct nf_conn *ct)
 	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum;
 }
 
+#define nf_ct_tuple(ct, dir) (&(ct)->tuplehash[dir].tuple)
+
 /* get master conntrack via master expectation */
 #define master_ct(conntr) (conntr->master)
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2d7d69f..3553f39 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -346,8 +346,6 @@ nla_put_failure:
 	return -1;
 }
 
-#define tuple(ct, dir) (&(ct)->tuplehash[dir].tuple)
-
 static int
 ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 		    int event, const struct nf_conn *ct)
@@ -369,14 +367,14 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_ORIG | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
-	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_ORIGINAL)) < 0)
+	if (ctnetlink_dump_tuples(skb, nf_ct_tuple(ct, IP_CT_DIR_ORIGINAL)) < 0)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_REPLY | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
-	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_REPLY)) < 0)
+	if (ctnetlink_dump_tuples(skb, nf_ct_tuple(ct, IP_CT_DIR_REPLY)) < 0)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
@@ -509,7 +507,8 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	if (!item->report && !nfnetlink_has_listeners(group))
 		return NOTIFY_DONE;
 
-	skb = ctnetlink_alloc_skb(tuple(ct, IP_CT_DIR_ORIGINAL), GFP_ATOMIC);
+	skb = ctnetlink_alloc_skb(nf_ct_tuple(ct, IP_CT_DIR_ORIGINAL),
+				  GFP_ATOMIC);
 	if (!skb)
 		goto errout;
 
@@ -528,14 +527,14 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_ORIG | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
-	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_ORIGINAL)) < 0)
+	if (ctnetlink_dump_tuples(skb, nf_ct_tuple(ct, IP_CT_DIR_ORIGINAL)) < 0)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_REPLY | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
-	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_REPLY)) < 0)
+	if (ctnetlink_dump_tuples(skb, nf_ct_tuple(ct, IP_CT_DIR_REPLY)) < 0)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
