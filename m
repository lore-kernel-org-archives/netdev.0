From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] ipv6: gre: fix wrong skb->protocol in WCCP
Date: Mon, 24 Nov 2014 11:25:15 +0100
Message-ID: <1416824715-28733-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	Yuri Chislov <yuri.chislov@gmail.com>,
	Dmitry Kozlov <xeb@mail.ru>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753275AbaKXKZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 05:25:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuri Chislov <yuri.chislov@gmail.com>

When using GRE redirection in WCCP, it sets the wrong skb->protocol,
that is, ETH_P_IP instead of ETH_P_IPV6 for the encapuslated traffic.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Cc: Dmitry Kozlov <xeb@mail.ru>
Signed-off-by: Yuri Chislov <yuri.chislov@gmail.com>
Tested-by: Yuri Chislov <yuri.chislov@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Also checked back with Dmitry, it was a copy-paste error from the
 IPv4 implementation.

 net/ipv6/ip6_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 4564e1f..0e32d2e 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -502,11 +502,11 @@ static int ip6gre_rcv(struct sk_buff *skb)
 
 		skb->protocol = gre_proto;
 		/* WCCP version 1 and 2 protocol decoding.
-		 * - Change protocol to IP
+		 * - Change protocol to IPv6
 		 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
 		 */
 		if (flags == 0 && gre_proto == htons(ETH_P_WCCP)) {
-			skb->protocol = htons(ETH_P_IP);
+			skb->protocol = htons(ETH_P_IPV6);
 			if ((*(h + offset) & 0xF0) != 0x40)
 				offset += 4;
 		}
-- 
1.7.11.7
