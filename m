From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/20] net: ipvs: sctp: add missing verdict assignments in sctp_conn_schedule
Date: Mon,  4 Nov 2013 22:50:39 +0100
Message-ID: <1383601842-4570-18-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>

If skb_header_pointer() fails, we need to assign a verdict, that is
NF_DROP in this case, otherwise, we would leave the verdict from
conn_schedule() uninitialized when returning.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 23e596e..9ca7aa0 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -20,13 +20,18 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	sctp_sctphdr_t *sh, _sctph;
 
 	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
-	if (sh == NULL)
+	if (sh == NULL) {
+		*verdict = NF_DROP;
 		return 0;
+	}
 
 	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
 				 sizeof(_schunkh), &_schunkh);
-	if (sch == NULL)
+	if (sch == NULL) {
+		*verdict = NF_DROP;
 		return 0;
+	}
+
 	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	rcu_read_lock();
-- 
1.7.10.4

