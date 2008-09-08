From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 14/33] netns ct: cleanup after L3 and L4 proto unregister in every netns
Date: Mon,  8 Sep 2008 07:02:51 +0400
Message-ID: <1220842990-30500-14-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 3a2f7ef..a59a307 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -207,6 +207,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
 
 void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
+	struct net *net;
+
 	BUG_ON(proto->l3proto >= AF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -219,7 +221,8 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(&init_net, kill_l3proto, proto);
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, kill_l3proto, proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
@@ -316,6 +319,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
 
 void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 {
+	struct net *net;
+
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -328,7 +333,8 @@ void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(&init_net, kill_l4proto, l4proto);
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
