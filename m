From: kaber@trash.net
Subject: [PATCH 48/72] ipvs: fix CHECKSUM_PARTIAL for TUN method
Date: Thu, 21 Oct 2010 17:19:35 +0200
Message-ID: <1287674399-31455-49-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60009 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180Ab0JUPUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:13 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

 	The recent change in IP_VS_XMIT_TUNNEL to set
CHECKSUM_NONE is not correct. After adding IPIP header
skb->csum becomes invalid but the CHECKSUM_PARTIAL
case must be supported. So, use skb_forward_csum() which is
most suitable for us to allow local clients to send IPIP
to remote real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 94b53b4..63cc0fe 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -222,7 +222,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 		__ret = ip_vs_confirm_conntrack(skb, cp);	\
 	if (__ret == NF_ACCEPT) {				\
 		nf_reset(skb);					\
-		(skb)->ip_summed = CHECKSUM_NONE;		\
+		skb_forward_csum(skb);				\
 	}							\
 	__ret;							\
 })
-- 
1.7.1

