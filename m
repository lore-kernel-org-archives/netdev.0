From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] ipvs: change comparison on sync_refresh_period
Date: Fri, 28 Apr 2017 12:11:59 +0200
Message-ID: <20170428101159.9810-3-horms@verge.net.au>
References: <20170428101159.9810-1-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>,
        Aaron Conole <aconole@bytheb.org>,
        Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20170428101159.9810-1-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aaron Conole <aconole@bytheb.org>

The sync_refresh_period variable is unsigned, so it can never be < 0.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 30d6b2cc00a0..0e5b64a75da0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -520,7 +520,7 @@ static int ip_vs_sync_conn_needed(struct netns_ipvs *ipvs,
 		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE) &&
 		    pkts % sync_period != sysctl_sync_threshold(ipvs))
 			return 0;
-	} else if (sync_refresh_period <= 0 &&
+	} else if (!sync_refresh_period &&
 		   pkts != sysctl_sync_threshold(ipvs))
 		return 0;
 
-- 
2.12.2.816.g2cccc81164

