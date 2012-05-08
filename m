From: pablo@netfilter.org
Subject: [PATCH 12/25] ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
Date: Tue,  8 May 2012 09:49:41 +0200
Message-ID: <1336463394-3119-13-git-send-email-pablo@netfilter.org>
References: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

	As IP_VS_CONN_F_NOOUTPUT is derived from the
forwarding method we should get it from conn_flags just
like we do it for IP_VS_CONN_F_FWD_MASK bits when binding
to real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4a09b78..f562e63 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -567,7 +567,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
 			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
 		/* connections inherit forwarding method from dest */
-		cp->flags &= ~IP_VS_CONN_F_FWD_MASK;
+		cp->flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
 	}
 	cp->flags |= conn_flags;
 	cp->dest = dest;
-- 
1.7.9.5

