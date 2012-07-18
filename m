From: Claudiu Ghioc <claudiughioc@gmail.com>
Subject: [PATCH v2] ipvs: fixed sparse warning
Date: Wed, 18 Jul 2012 12:10:22 +0300
Message-ID: <1342602622-2728-1-git-send-email-claudiu.ghioc@gmail.com>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org,
	kaber@trash.net, claudiu.ghioc@gmail.com, daniel.baluta@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53596 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab2GRJKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 05:10:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed the following sparse warnings, wether CONFIG_SYSCTL
is defined or not:
*       warning: symbol 'ip_vs_control_net_init_sysctl' was not
	declared. Should it be static?
*       warning: symbol 'ip_vs_control_net_cleanup_sysctl' was
	not declared. Should it be static?

Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d43e3c1..044e845 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3674,7 +3674,7 @@ static void ip_vs_genl_unregister(void)
  * per netns intit/exit func.
  */
 #ifdef CONFIG_SYSCTL
-int __net_init ip_vs_control_net_init_sysctl(struct net *net)
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3742,7 +3742,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3753,8 +3753,8 @@ void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 
 #else
 
-int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 
-- 
1.7.4.4
