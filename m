From: pablo@netfilter.org
Subject: [PATCH 4/8] ipvs: reset ipvs pointer in netns
Date: Mon, 30 Apr 2012 17:16:51 +0200
Message-ID: <1335799015-2003-5-git-send-email-pablo@netfilter.org>
References: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

	Make sure net->ipvs is reset on netns cleanup or failed
initialization. It is needed for IPVS applications to know that
IPVS core is not loaded in netns.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2555816..260b9ef 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1924,6 +1924,7 @@ protocol_fail:
 control_fail:
 	ip_vs_estimator_net_cleanup(net);
 estimator_fail:
+	net->ipvs = NULL;
 	return -ENOMEM;
 }
 
@@ -1936,6 +1937,7 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 	ip_vs_control_net_cleanup(net);
 	ip_vs_estimator_net_cleanup(net);
 	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
+	net->ipvs = NULL;
 }
 
 static void __net_exit __ip_vs_dev_cleanup(struct net *net)
-- 
1.7.9.5

