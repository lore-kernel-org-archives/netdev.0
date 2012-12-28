From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 13/19] netfilter: ipv4: move registration codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:40 +0800
Message-ID: <1356662206-2260-14-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the proto (un)registration codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 933da838..39521ca 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -501,6 +501,18 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		goto cleanup_pernet;
 	}
 
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp4);
+	if (ret < 0)
+		goto cleanup_tcp4;
+
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp4);
+	if (ret < 0)
+		goto cleanup_udp4;
+
+	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmp);
+	if (ret < 0)
+		goto cleanup_icmp;
+
 	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
 	if (ret < 0)
 		goto cleanup_proto;
@@ -515,6 +527,12 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
 #endif
  cleanup_proto:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
+ cleanup_icmp:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
+ cleanup_udp4:
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
+ cleanup_tcp4:
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
  cleanup_pernet:
 	unregister_pernet_subsys(&ipv4_net_ops);
@@ -529,7 +547,11 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	nf_conntrack_ipv4_compat_fini();
 #endif
+
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
-- 
1.7.11.7

