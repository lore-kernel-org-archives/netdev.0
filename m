From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/6] IPVS: Only match pe_data created by the same pe
Date: Tue, 16 Nov 2010 15:34:53 +0900
Message-ID: <1289889298-17287-2-git-send-email-horms__3080.02425958893$1289889349$gmane$org@verge.net.au>
References: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Cc: Simon Horman <horms@verge.net.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org,
	n
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:32994 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab0KPGfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 01:35:31 -0500
In-Reply-To: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only match persistence engine data if it was
created by the same persistence engine.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 64a9ca3..261db1a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -354,7 +354,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (p->pe_data && p->pe->ct_match) {
-			if (p->pe->ct_match(p, cp))
+			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
 				goto out;
 			continue;
 		}
-- 
1.7.2.3

