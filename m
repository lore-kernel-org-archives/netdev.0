From: kaber@trash.net
Subject: [PATCH 1/2] IPVS: Use correct lock in SCTP module
Date: Wed,  9 Feb 2011 15:33:46 +0100
Message-ID: <1297262027-26237-2-git-send-email-kaber@trash.net>
References: <1297262027-26237-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1297262027-26237-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

Use sctp_app_lock instead of tcp_app_lock in the SCTP protocol module.

This appears to be a typo introduced by the netns changes.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index fb2d04a..b027ccc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1101,7 +1101,7 @@ static void __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
-	spin_lock_init(&ipvs->tcp_app_lock);
+	spin_lock_init(&ipvs->sctp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
 							sizeof(sctp_timeouts));
 }
-- 
1.7.2.3

