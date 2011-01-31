From: kaber@trash.net
Subject: [PATCH 3/7] IPVS netns BUG, register sysctl for root ns
Date: Mon, 31 Jan 2011 21:10:16 +0100
Message-ID: <1296504620-820-4-git-send-email-kaber@trash.net>
References: <1296504620-820-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296504620-820-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

The newly created table was not used when register sysctl for a new namespace.
I.e. sysctl doesn't work for other than root namespace (init_net)

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 68b8033..98df59a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3556,7 +3556,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 
 
 	ipvs->sysctl_hdr = register_net_sysctl_table(net, net_vs_ctl_path,
-						  vs_vars);
+						     tbl);
 	if (ipvs->sysctl_hdr == NULL)
 		goto err_reg;
 	ip_vs_new_estimator(net, ipvs->tot_stats);
-- 
1.7.2.3

