From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 10/12: nf_conntrack: add generic function to get len of generic policy
Date: Thu, 26 Mar 2009 20:02:44 +0100 (MET)
Message-ID: <20090326190238.23365.70803.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 5c0de29d06318ec8f6e3ba0d17d62529dbbdc1e8
Author: Holger Eitzenberger <holger@eitzenberger.org>
Date:   Wed Mar 25 21:52:17 2009 +0100

    netfilter: nf_conntrack: add generic function to get len of generic policy
    
    Usefull for all protocols which do not add additional data, such
    as GRE or UDPlite.
    
    Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index a120990..ba32ed7 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -113,6 +113,7 @@ extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
 				      const struct nf_conntrack_tuple *tuple);
 extern int nf_ct_port_nlattr_to_tuple(struct nlattr *tb[],
 				      struct nf_conntrack_tuple *t);
+extern int nf_ct_port_nlattr_tuple_size(void);
 extern const struct nla_policy nf_ct_port_nla_policy[];
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c55bbdc..b182b30 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -921,6 +921,12 @@ int nf_ct_port_nlattr_to_tuple(struct nlattr *tb[],
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_ct_port_nlattr_to_tuple);
+
+int nf_ct_port_nlattr_tuple_size(void)
+{
+	return nla_policy_len(nf_ct_port_nla_policy, CTA_PROTO_MAX + 1);
+}
+EXPORT_SYMBOL_GPL(nf_ct_port_nlattr_tuple_size);
 #endif
 
 /* Used by ipt_REJECT and ip6t_REJECT. */
