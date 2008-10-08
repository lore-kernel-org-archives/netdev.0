From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 14/14] ipv6: remove unused not init_ipv6_mibs/cleanup_ipv6_mibs
Date: Wed,  8 Oct 2008 15:52:02 +0400
Message-ID: <1223466722-8169-14-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34444 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904AbYJHLyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:02 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/af_inet6.c |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6b509d7..050e14b 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -795,15 +795,6 @@ static void ipv6_packet_cleanup(void)
 	dev_remove_pack(&ipv6_packet_type);
 }
 
-static int __init init_ipv6_mibs(void)
-{
-	return 0;
-}
-
-static void cleanup_ipv6_mibs(void)
-{
-}
-
 static int __net_init ipv6_init_mibs(struct net *net)
 {
 	if (snmp_mib_init((void **)net->mib.udp_stats_in6,
@@ -935,11 +926,6 @@ static int __init inet6_init(void)
 	if (err)
 		goto out_sock_register_fail;
 
-	/* Initialise ipv6 mibs */
-	err = init_ipv6_mibs();
-	if (err)
-		goto out_unregister_sock;
-
 #ifdef CONFIG_SYSCTL
 	err = ipv6_static_sysctl_register();
 	if (err)
@@ -1073,8 +1059,6 @@ register_pernet_fail:
 	ipv6_static_sysctl_unregister();
 static_sysctl_fail:
 #endif
-	cleanup_ipv6_mibs();
-out_unregister_sock:
 	sock_unregister(PF_INET6);
 	rtnl_unregister_all(PF_INET6);
 out_sock_register_fail:
@@ -1131,7 +1115,6 @@ static void __exit inet6_exit(void)
 #ifdef CONFIG_SYSCTL
 	ipv6_static_sysctl_unregister();
 #endif
-	cleanup_ipv6_mibs();
 	proto_unregister(&rawv6_prot);
 	proto_unregister(&udplitev6_prot);
 	proto_unregister(&udpv6_prot);
-- 
1.5.3.rc5

