From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 5/6] netfilter: add generic function to get len of generic policy
Date: Mon, 16 Mar 2009 23:07:04 +0100
Message-ID: <20090316221141.055455350@jonathan.eitzenberger.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:55481 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758970AbZCPWLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 18:11:46 -0400
Content-Disposition: inline; filename=netfilter-add-generic-fn-for-generic-policy.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usefull for all protocols which do not add additional data, such
as GRE or UDPlite.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next-2.6/include/net/netfilter/nf_conntrack_l4proto.h
===================================================================
--- net-next-2.6.orig/include/net/netfilter/nf_conntrack_l4proto.h
+++ net-next-2.6/include/net/netfilter/nf_conntrack_l4proto.h
@@ -121,6 +121,7 @@ extern int nf_ct_port_tuple_to_nlattr(st
 				      const struct nf_conntrack_tuple *tuple);
 extern int nf_ct_port_nlattr_to_tuple(struct nlattr *tb[],
 				      struct nf_conntrack_tuple *t);
+extern int nf_ct_port_nlattr_tuple_size(void);
 extern const struct nla_policy nf_ct_port_nla_policy[];
 
 #ifdef CONFIG_SYSCTL
Index: net-next-2.6/net/netfilter/nf_conntrack_core.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_core.c
+++ net-next-2.6/net/netfilter/nf_conntrack_core.c
@@ -902,6 +902,12 @@ int nf_ct_port_nlattr_to_tuple(struct nl
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
