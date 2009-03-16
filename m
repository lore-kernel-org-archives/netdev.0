From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 3/6] netfilter: limit the length of the helper name
Date: Mon, 16 Mar 2009 23:07:02 +0100
Message-ID: <20090316221138.326410717@jonathan.eitzenberger.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=netfilter-limit-the-length-of-the-helper-name.diff
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is necessary in order to have an upper bound for Netlink
message calculation, which is not a problem at all, as there
are no helpers with a longer name.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next-2.6/include/net/netfilter/nf_conntrack_helper.h
===================================================================
--- net-next-2.6.orig/include/net/netfilter/nf_conntrack_helper.h
+++ net-next-2.6/include/net/netfilter/nf_conntrack_helper.h
@@ -14,6 +14,8 @@
 
 struct module;
 
+#define NF_CT_HELPER_NAME_LEN	16
+
 struct nf_conntrack_helper
 {
 	struct hlist_node hnode;	/* Internal use. */
Index: net-next-2.6/net/netfilter/nf_conntrack_helper.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_helper.c
+++ net-next-2.6/net/netfilter/nf_conntrack_helper.c
@@ -142,6 +142,7 @@ int nf_conntrack_helper_register(struct 
 
 	BUG_ON(me->expect_policy == NULL);
 	BUG_ON(me->expect_class_max >= NF_CT_MAX_EXPECT_CLASSES);
+	BUG_ON(strlen(me->name) >= NF_CT_HELPER_NAME_LEN - 1);
 
 	mutex_lock(&nf_ct_helper_mutex);
 	hlist_add_head_rcu(&me->hnode, &nf_ct_helper_hash[h]);

-- 
