From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 2/3] netfilter: add generic function to get len of generic policy
Date: Wed, 25 Mar 2009 21:34:06 +0100
Message-ID: <20090325204601.730465387@jonathan.eitzenberger.org>
References: <20090325203404.581023828@jonathan.eitzenberger.org>
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:62884 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbZCYUqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 16:46:07 -0400
Content-Disposition: inline; filename=netfilter-add-generic-fn-for-generic-policy.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usefull for all protocols which do not add additional data, such
as GRE or UDPlite.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: nf-next-2.6/include/net/netfilter/nf_conntrack_l4proto.h
===================================================================
--- nf-next-2.6.orig/include/net/netfilter/nf_conntrack_l4proto.h
+++ nf-next-2.6/include/net/netfilter/nf_conntrack_l4proto.h
@@ -113,6 +113,7 @@ extern int nf_ct_port_tuple_to_nlattr(st
 				      const struct nf_conntrack_tuple *tuple);
 extern int nf_ct_port_nlattr_to_tuple(struct nlattr *tb[],
 				      struct nf_conntrack_tuple *t);
+extern int nf_ct_port_nlattr_tuple_size(void);
 extern const struct nla_policy nf_ct_port_nla_policy[];
 
 #ifdef CONFIG_SYSCTL
Index: nf-next-2.6/net/netfilter/nf_conntrack_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_core.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_core.c
@@ -906,6 +906,12 @@ int nf_ct_port_nlattr_to_tuple(struct nl
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

-- 
