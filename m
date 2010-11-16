From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/6] IPVS: Remove useless { } block from ip_vs_process_message()
Date: Tue, 16 Nov 2010 15:34:55 +0900
Message-ID: <1289889298-17287-4-git-send-email-horms__11793.00444569$1289889364$gmane$org@verge.net.au>
References: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Cc: Simon Horman <horms@verge.net.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org,
	n
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33004 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab0KPGfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 01:35:33 -0500
In-Reply-To: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

