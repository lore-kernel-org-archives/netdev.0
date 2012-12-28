From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 10/19] netfilter: ipv4: register l3proto ipv4 in module_init
Date: Fri, 28 Dec 2012 10:36:37 +0800
Message-ID: <1356662206-2260-11-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:12405 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab2L1Civ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:51 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register nf_conntrack_l3proto_ipv4 in module_init,
and unregister it in module_exit.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index afd3a96..a942add 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -500,6 +500,10 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
 		goto cleanup_pernet;
 	}
+
+	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
+	if (ret < 0)
+		goto cleanup_proto;
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	ret = nf_conntrack_ipv4_compat_init();
 	if (ret < 0)
@@ -508,8 +512,10 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 	return ret;
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
  cleanup_hooks:
-	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
+	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
 #endif
+ cleanup_proto:
+	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
  cleanup_pernet:
 	unregister_pernet_subsys(&ipv4_net_ops);
  cleanup_sockopt:
@@ -523,6 +529,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	nf_conntrack_ipv4_compat_fini();
 #endif
+	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
-- 
1.7.11.7
