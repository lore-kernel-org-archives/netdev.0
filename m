From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/12: limit the length of the helper name
Date: Thu, 26 Mar 2009 20:02:38 +0100 (MET)
Message-ID: <20090326190233.23365.26846.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39218 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758837AbZCZTCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 15:02:40 -0400
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit af9d32ad6718b9a80fa89f557cc1fbb63a93ec15
Author: Holger Eitzenberger <holger@eitzenberger.org>
Date:   Wed Mar 25 18:44:01 2009 +0100

    netfilter: limit the length of the helper name
    
    This is necessary in order to have an upper bound for Netlink
    message calculation, which is not a problem at all, as there
    are no helpers with a longer name.
    
    Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 66d65a7..ee2a4b3 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -14,6 +14,8 @@
 
 struct module;
 
+#define NF_CT_HELPER_NAME_LEN	16
+
 struct nf_conntrack_helper
 {
 	struct hlist_node hnode;	/* Internal use. */
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index a51bdac..805cfdd 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -142,6 +142,7 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 
 	BUG_ON(me->expect_policy == NULL);
 	BUG_ON(me->expect_class_max >= NF_CT_MAX_EXPECT_CLASSES);
+	BUG_ON(strlen(me->name) > NF_CT_HELPER_NAME_LEN - 1);
 
 	mutex_lock(&nf_ct_helper_mutex);
 	hlist_add_head_rcu(&me->hnode, &nf_ct_helper_hash[h]);
