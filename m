From: pablo@netfilter.org
Subject: [PATCH 04/18] netfilter: nf_conntrack: add nf_ct_kfree_compat_sysctl_table
Date: Fri,  6 Jul 2012 13:16:54 +0200
Message-ID: <1341573428-3204-5-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43396 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933508Ab2GFLS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:18:56 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch is a cleanup.

It adds nf_ct_kfree_compat_sysctl_table to release l4proto's
compat sysctl table and set the compat sysctl table point to NULL.

This new function will be used by follow-up patches.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h |    8 ++++++++
 net/netfilter/nf_conntrack_proto.c           |    3 +--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 5dd60f2..08bb571 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -124,6 +124,14 @@ extern int nf_conntrack_l4proto_register(struct net *net,
 extern void nf_conntrack_l4proto_unregister(struct net *net,
 					    struct nf_conntrack_l4proto *proto);
 
+static inline void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
+{
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	kfree(pn->ctl_compat_table);
+	pn->ctl_compat_table = NULL;
+#endif
+}
+
 /* Generic netlink helpers */
 extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
 				      const struct nf_conntrack_tuple *tuple);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 6f4b6f3..9d6b6ab 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -361,8 +361,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 		if (err == 0)
 			goto out;
 
-		kfree(pn->ctl_compat_table);
-		pn->ctl_compat_table = NULL;
+		nf_ct_kfree_compat_sysctl_table(pn);
 		nf_ct_unregister_sysctl(&pn->ctl_table_header,
 					&pn->ctl_table,
 					&pn->users);
-- 
1.7.10
