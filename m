From: kaber@trash.net
Subject: [PATCH 23/26] netfilter: ipset: add missing break statemtns in ip_set_get_ip_port()
Date: Thu,  3 Feb 2011 00:12:01 +0100
Message-ID: <1296688324-7830-24-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44721 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413Ab1BBXMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:12:35 -0500
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Don't fall through in the switch statement, otherwise IPv4 headers
are incorrectly parsed again as IPv6 and the return value will always
be 'false'.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_getport.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
index 76737bb..4dd2785 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -118,8 +118,10 @@ ip_set_get_ip_port(const struct sk_buff *skb, u8 pf, bool src, __be16 *port)
 	switch (pf) {
 	case AF_INET:
 		ret = ip_set_get_ip4_port(skb, src, port, &proto);
+		break;
 	case AF_INET6:
 		ret = ip_set_get_ip6_port(skb, src, port, &proto);
+		break;
 	default:
 		return false;
 	}
-- 
1.7.2.3

