From: pablo@netfilter.org
Subject: [PATCH 03/10] ipvs: fixed sparse warning
Date: Thu, 23 Aug 2012 01:38:39 +0200
Message-ID: <1345678726-3109-4-git-send-email-pablo@netfilter.org>
References: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Claudiu Ghioc <claudiughioc@gmail.com>

Removed the following sparse warnings, wether CONFIG_SYSCTL
is defined or not:
*       warning: symbol 'ip_vs_control_net_init_sysctl' was not
	declared. Should it be static?
*       warning: symbol 'ip_vs_control_net_cleanup_sysctl' was
	not declared. Should it be static?

Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 84444dd..d6d5cca 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3675,7 +3675,7 @@ static void ip_vs_genl_unregister(void)
  * per netns intit/exit func.
  */
 #ifdef CONFIG_SYSCTL
-int __net_init ip_vs_control_net_init_sysctl(struct net *net)
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3743,7 +3743,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3754,8 +3754,8 @@ void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 
 #else
 
-int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 
-- 
1.7.10.4

