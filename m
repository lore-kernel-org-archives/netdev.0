From: kaber@trash.net
Subject: [PATCH 05/28] ipvs: lvs sctp protocol handler is incorrectly invoked ip_vs_app_pkt_out
Date: Mon,  2 Aug 2010 21:57:22 +0200
Message-ID: <1280779065-9333-6-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35364 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab0HBT56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:57:58 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaoyu Du <tingsrain@gmail.com>

lvs sctp protocol handler is incorrectly invoked ip_vs_app_pkt_out
Since there's no sctp helpers at present, it does the same thing as
ip_vs_app_pkt_in.

Signed-off-by: Xiaoyu Du <tingsrain@gmail.com>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index c9a3f7a..db55759 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -173,7 +173,7 @@ sctp_dnat_handler(struct sk_buff *skb,
 			return 0;
 
 		/* Call application helper if needed */
-		if (!ip_vs_app_pkt_out(cp, skb))
+		if (!ip_vs_app_pkt_in(cp, skb))
 			return 0;
 	}
 
-- 
1.7.1

