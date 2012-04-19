From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 08/19] net ipv4: Remove the unneeded registration of an empty net/ipv4/neigh
Date: Thu, 19 Apr 2012 16:32:39 -0700
Message-ID: <m1y5prfgbs.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47663 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929Ab2DSX2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:28:39 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sysctl no longer requires explicit creation of directories.  The neigh
directory is always populated with at least a default entry so this
won't cause any user visible changes.

Delete the ipv4_path and the ipv4_skeleton these are no longer needed.

Directly register the ipv4_route_table.

And since I am an idiot remove the header definitions that I should
have removed in the previous patch.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/ipv6.h |    2 --
 net/ipv4/route.c   |   19 +------------------
 2 files changed, 1 insertions(+), 20 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 2d3fca37..e1a85ad 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -661,8 +661,6 @@ extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
 extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
 extern int ipv6_sysctl_register(void);
 extern void ipv6_sysctl_unregister(void);
-extern int ipv6_static_sysctl_register(void);
-extern void ipv6_static_sysctl_unregister(void);
 #endif
 
 #endif /* _NET_IPV6_H */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f9c474e..4dd8027 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3343,23 +3343,6 @@ static ctl_table ipv4_route_table[] = {
 	{ }
 };
 
-static struct ctl_table empty[1];
-
-static struct ctl_table ipv4_skeleton[] =
-{
-	{ .procname = "route", 
-	  .mode = 0555, .child = ipv4_route_table},
-	{ .procname = "neigh", 
-	  .mode = 0555, .child = empty},
-	{ }
-};
-
-static __net_initdata struct ctl_path ipv4_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ },
-};
-
 static struct ctl_table ipv4_route_flush_table[] = {
 	{
 		.procname	= "flush",
@@ -3514,6 +3497,6 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
-	kmemleak_not_leak(register_net_sysctl_table(&init_net, ipv4_path, ipv4_skeleton));
+	register_net_sysctl(&init_net, "net/ipv4/route", ipv4_route_table);
 }
 #endif
-- 
1.7.2.5
