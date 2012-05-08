From: pablo@netfilter.org
Subject: [PATCH 11/25] ipvs: use GFP_KERNEL allocation where possible
Date: Tue,  8 May 2012 02:22:05 +0200
Message-ID: <1336436539-5880-12-git-send-email-pablo@netfilter.org>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <levinsasha928@gmail.com>

Use GFP_KERNEL instead of GFP_ATOMIC when registering an ipvs protocol.

This is safe since it will always run from a process context.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a981b7c..8726488 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -71,7 +71,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash = IP_VS_PROTO_HASH(pp->protocol);
 	struct ip_vs_proto_data *pd =
-			kzalloc(sizeof(struct ip_vs_proto_data), GFP_ATOMIC);
+			kzalloc(sizeof(struct ip_vs_proto_data), GFP_KERNEL);
 
 	if (!pd)
 		return -ENOMEM;
-- 
1.7.9.5

