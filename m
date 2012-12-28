From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 11/19] netfilter: ipv6: register l3proto ipv6 in module_init
Date: Fri, 28 Dec 2012 10:36:38 +0800
Message-ID: <1356662206-2260-12-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36421 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753142Ab2L1Ciu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:50 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register nf_conntrack_l3proto_ipv6 in module_init,
and unregister it in module_exit.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 469a15f..07ec50b 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -499,8 +499,13 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 		       "hook.\n");
 		goto cleanup_ipv6;
 	}
+	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv6);
+	if (ret < 0)
+		goto cleanup_proto;
 	return ret;
 
+ cleanup_proto:
+	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
  cleanup_ipv6:
 	unregister_pernet_subsys(&ipv6_net_ops);
  cleanup_pernet:
@@ -511,6 +516,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
+	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	unregister_pernet_subsys(&ipv6_net_ops);
 	nf_unregister_sockopt(&so_getorigdst6);
-- 
1.7.11.7
