From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 07/19] net ipv6: Remove unneded registration of an empty net/ipv6/neigh
Date: Thu, 19 Apr 2012 16:26:19 -0700
Message-ID: <m18vhrgv6s.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46188 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab2DSXWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:22:19 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sysctl no longer requires explicit creation of directories.  The neigh
directory is always populated with at least a default entry so this
should cause no user visible changes.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv6/af_inet6.c        |   15 ---------------
 net/ipv6/sysctl_net_ipv6.c |   27 ---------------------------
 2 files changed, 0 insertions(+), 42 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 8ed1b93..461e789 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -1111,11 +1111,6 @@ static int __init inet6_init(void)
 	if (err)
 		goto out_sock_register_fail;
 
-#ifdef CONFIG_SYSCTL
-	err = ipv6_static_sysctl_register();
-	if (err)
-		goto static_sysctl_fail;
-#endif
 	tcpv6_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
 
 	/*
@@ -1242,10 +1237,6 @@ ipmr_fail:
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
 register_pernet_fail:
-#ifdef CONFIG_SYSCTL
-	ipv6_static_sysctl_unregister();
-static_sysctl_fail:
-#endif
 	sock_unregister(PF_INET6);
 	rtnl_unregister_all(PF_INET6);
 out_sock_register_fail:
@@ -1272,9 +1263,6 @@ static void __exit inet6_exit(void)
 	/* Disallow any further netlink messages */
 	rtnl_unregister_all(PF_INET6);
 
-#ifdef CONFIG_SYSCTL
-	ipv6_sysctl_unregister();
-#endif
 	udpv6_exit();
 	udplitev6_exit();
 	tcpv6_exit();
@@ -1302,9 +1290,6 @@ static void __exit inet6_exit(void)
 	rawv6_exit();
 
 	unregister_pernet_subsys(&inet6_net_ops);
-#ifdef CONFIG_SYSCTL
-	ipv6_static_sysctl_unregister();
-#endif
 	proto_unregister(&rawv6_prot);
 	proto_unregister(&udplitev6_prot);
 	proto_unregister(&udpv6_prot);
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 99279c8..cf1e96a 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -16,18 +16,6 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
-static struct ctl_table empty[1];
-
-static ctl_table ipv6_static_skeleton[] = {
-	{
-		.procname	= "neigh",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= empty,
-	},
-	{ }
-};
-
 static ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "route",
@@ -160,18 +148,3 @@ void ipv6_sysctl_unregister(void)
 	unregister_net_sysctl_table(ip6_header);
 	unregister_pernet_subsys(&ipv6_sysctl_net_ops);
 }
-
-static struct ctl_table_header *ip6_base;
-
-int ipv6_static_sysctl_register(void)
-{
-	ip6_base = register_net_sysctl_table(&init_net, net_ipv6_ctl_path, ipv6_static_skeleton);
-	if (ip6_base == NULL)
-		return -ENOMEM;
-	return 0;
-}
-
-void ipv6_static_sysctl_unregister(void)
-{
-	unregister_net_sysctl_table(ip6_base);
-}
-- 
1.7.2.5
