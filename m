From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/10] ipvs: fix crash with sync protocol v0 and FTP
Date: Thu, 23 Jul 2015 01:00:49 +0200
Message-ID: <1437606052-5179-8-git-send-email-pablo@netfilter.org>
References: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54443 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414AbbGVWz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 18:55:26 -0400
In-Reply-To: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

Fix crash in 3.5+ if FTP is used after switching
sync_version to 0.

Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index b08ba95..d99ad93 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -612,7 +612,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 			pkts = atomic_add_return(1, &cp->in_pkts);
 		else
 			pkts = sysctl_sync_threshold(ipvs);
-		ip_vs_sync_conn(net, cp->control, pkts);
+		ip_vs_sync_conn(net, cp, pkts);
 	}
 }
 
-- 
1.7.10.4
