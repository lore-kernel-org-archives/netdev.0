From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/18] ipvs: allow rescheduling after RST
Date: Tue, 15 Mar 2016 02:27:49 +0100
Message-ID: <1458005282-24665-6-git-send-email-pablo@netfilter.org>
References: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1458005282-24665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

"RFC 5961, 4.2. Mitigation" describes a mechanism to request
client to confirm with RST the restart of TCP connection
before resending its SYN. As result, IPVS can see SYNs for
existing connection in CLOSE state. Add check to allow
rescheduling in this state.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4da5600..b9a4082 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1089,6 +1089,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
 	switch (cp->protocol) {
 	case IPPROTO_TCP:
 		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
+		       (cp->state == IP_VS_TCP_S_CLOSE) ||
 			((conn_reuse_mode & 2) &&
 			 (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
 			 (cp->flags & IP_VS_CONN_F_NOOUTPUT));
-- 
2.1.4

