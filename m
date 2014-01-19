From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next v2] ipv6: enable anycast addresses as source addresses in ICMPv6 error messages
Date: Sun, 19 Jan 2014 17:00:36 +0100
Message-ID: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com>
Cc: David Stevens <dlstevens@us.ibm.com>,
	Bill Fink <billfink@mindspring.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:55662 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbaASQUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 11:20:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Uses ipv6_anycast_destination() in icmp6_send().

Suggested-by: Bill Fink <billfink@mindspring.com>
Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
v2: Consideration of a Hannes's concern : No sysctl is needed for this change.
    No need for a new check function.

 net/ipv6/icmp.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 902405d..f81f596 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -413,7 +413,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 */
 	addr_type = ipv6_addr_type(&hdr->daddr);
 
-	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0))
+	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0) ||
+	    ipv6_anycast_destination(skb))
 		saddr = &hdr->daddr;
 
 	/*
