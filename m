From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6 -stable] ipvs: fix ipv6 hook registration for local replies
Date: Fri, 26 Sep 2014 13:43:43 +0200
Message-ID: <1411731824-15051-6-git-send-email-pablo@netfilter.org>
References: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411731824-15051-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

[ upstream commit eb90b0c734ad793d5f5bf230a9e9a4dcc48df8aa ]

commit fc604767613b6d2036cdc35b660bc39451040a47
("ipvs: changes for local real server") from 2.6.37
introduced DNAT support to local real server but the
IPv6 LOCAL_OUT handler ip_vs_local_reply6() is
registered incorrectly as IPv4 hook causing any outgoing
IPv4 traffic to be dropped depending on the IP header values.

Chris tracked down the problem to CONFIG_IP_VS_IPV6=y
Bug report: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349768

Cc: <stable@vger.kernel.org> # 3.16.x
Cc: <stable@vger.kernel.org> # 3.14.x
Cc: <stable@vger.kernel.org> # 3.12.x
Cc: <stable@vger.kernel.org> # 3.10.x
Reported-by: Chris J Arges <chris.j.arges@canonical.com>
Tested-by: Chris J Arges <chris.j.arges@canonical.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e683675..5c34e8d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1906,7 +1906,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 1,
 	},
-- 
1.7.10.4

