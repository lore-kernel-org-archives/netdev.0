From: pablo@netfilter.org
Subject: [PATCH 2/8] ipvs: fix crash in ip_vs_control_net_cleanup on unload
Date: Mon, 30 Apr 2012 17:16:49 +0200
Message-ID: <1335799015-2003-3-git-send-email-pablo@netfilter.org>
References: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

	commit 14e405461e664b777e2a5636e10b2ebf36a686ec (2.6.39)
("Add __ip_vs_control_{init,cleanup}_sysctl()")
introduced regression due to wrong __net_init for
__ip_vs_control_cleanup_sysctl. This leads to crash when
the ip_vs module is unloaded.

	Fix it by changing __net_init to __net_exit for
the function that is already renamed to ip_vs_control_net_cleanup_sysctl.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b3afe18..376d2b1 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3680,7 +3680,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
@@ -3692,7 +3692,7 @@ void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net)
 #else
 
 int __net_init ip_vs_control_net_init_sysctl(struct net *net) { return 0; }
-void __net_init ip_vs_control_net_cleanup_sysctl(struct net *net) { }
+void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net) { }
 
 #endif
 
-- 
1.7.9.5

