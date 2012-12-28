From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 18/19] netfilter: gre: move registration codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:45 +0800
Message-ID: <1356662206-2260-19-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:26245 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753212Ab2L1Ciz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:55 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the proto (un)registration codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_gre.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index f5f14c2..ea1f651 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -420,11 +420,25 @@ static struct pernet_operations proto_gre_net_ops = {
 
 static int __init nf_ct_proto_gre_init(void)
 {
-	return register_pernet_subsys(&proto_gre_net_ops);
+	int ret;
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
+	if (ret < 0)
+		goto out_gre4;
+
+	ret = register_pernet_subsys(&proto_gre_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
+out_gre4:
+	return ret;
 }
 
 static void __exit nf_ct_proto_gre_fini(void)
 {
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
 	unregister_pernet_subsys(&proto_gre_net_ops);
 }
 
-- 
1.7.11.7
