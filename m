From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipv6: fix 4in6 tunnel receive path
Date: Tue, 10 May 2016 16:08:17 +0200
Message-ID: <1462889297-12953-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:40920 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbcEJOJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 10:09:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Protocol for 4in6 tunnel is IPPROTO_IPIP. This was wrongly changed by
the last cleanup.

CC: Tom Herbert <tom@herbertland.com>
Fixes: 0d3c703a9d17 ("ipv6: Cleanup IPv6 tunnel receive path")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 50af7061ecdb..e79330f214bd 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -897,7 +897,7 @@ drop:
 
 static int ip4ip6_rcv(struct sk_buff *skb)
 {
-	return ipxip6_rcv(skb, IPPROTO_IP, &tpi_v4,
+	return ipxip6_rcv(skb, IPPROTO_IPIP, &tpi_v4,
 			  ip4ip6_dscp_ecn_decapsulate);
 }
 
-- 
2.8.1
