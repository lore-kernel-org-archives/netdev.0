From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 2/3] netfilter: ipvs: allow rescheduling after RST
Date: Thu, 18 Feb 2016 09:41:00 +0900
Message-ID: <1455756061-21834-3-git-send-email-horms@verge.net.au>
References: <1455756061-21834-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1455756061-21834-1-git-send-email-horms@verge.net.au>
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
index 4da560005b0e..0c1d3fef9a7c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1089,6 +1089,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
 	switch (cp->protocol) {
 	case IPPROTO_TCP:
 		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
+			cp->state == IP_VS_TCP_S_CLOSE ||
 			((conn_reuse_mode & 2) &&
 			 (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
 			 (cp->flags & IP_VS_CONN_F_NOOUTPUT));
-- 
2.1.4

