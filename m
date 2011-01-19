From: kaber@trash.net
Subject: [PATCH 18/79] IPVS: Remove useless { } block from ip_vs_process_message()
Date: Wed, 19 Jan 2011 20:14:18 +0100
Message-ID: <1295464519-21763-19-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51975 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab1ASTP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:27 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index a4dccbc..72b3d88 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -381,20 +381,18 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			}
 		}
 
-		{
-			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
-					      (union nf_inet_addr *)&s->caddr,
-					      s->cport,
-					      (union nf_inet_addr *)&s->vaddr,
-					      s->vport, &param)) {
-				pr_err("ip_vs_conn_fill_param_sync failed");
-				return;
-			}
-			if (!(flags & IP_VS_CONN_F_TEMPLATE))
-				cp = ip_vs_conn_in_get(&param);
-			else
-				cp = ip_vs_ct_in_get(&param);
+		if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
+					       (union nf_inet_addr *)&s->caddr,
+					       s->cport,
+					       (union nf_inet_addr *)&s->vaddr,
+					       s->vport, &param)) {
+			pr_err("ip_vs_conn_fill_param_sync failed");
+			return;
 		}
+		if (!(flags & IP_VS_CONN_F_TEMPLATE))
+			cp = ip_vs_conn_in_get(&param);
+		else
+			cp = ip_vs_ct_in_get(&param);
 		if (!cp) {
 			/*
 			 * Find the appropriate destination for the connection.
-- 
1.7.2.3

