From: kaber@trash.net
Subject: [PATCH 53/72] ipvs: inherit forwarding method in backup
Date: Thu, 21 Oct 2010 17:19:40 +0200
Message-ID: <1287674399-31455-54-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

 	Connections in backup server should inherit the
forwarding method from real server. It is a way to fix a
problem where the forwarding method in backup connection
is damaged by logical OR operation with the real server's
connection flags. And the change is needed for setups
where the backup server uses different forwarding method
for the same real servers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1d1a529..e9adecd 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -563,6 +563,8 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		 */
 		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
 			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
+		/* connections inherit forwarding method from dest */
+		cp->flags &= ~IP_VS_CONN_F_FWD_MASK;
 	}
 	cp->flags |= conn_flags;
 	cp->dest = dest;
-- 
1.7.1

