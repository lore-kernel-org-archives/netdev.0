From: Karsten Keil <kkeil@suse.de>
Subject: [PATCH] [IPv6] Do not use loopback as source address on other interfaces
Date: Wed, 18 Jun 2008 15:23:12 +0200
Message-ID: <20080618132312.GA25004@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Mironov <Mironov_Sergey@emc.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47031 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799AbYFRNXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 09:23:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4291 forbit the use of the loopback address as source outside a node
(paragraph 2.5.3).

The latest TAHI test release 4.0.1 does have a check for this (ICMPv6 test
v6LC.5.1.2 Part F), so it fails currently on Linux.

Signed-off-by: Sergey Mironov <Mironov_Sergey@emc.com>
Signed-off-by: Karsten Keil <kkeil@suse.de>
---
 net/ipv6/icmp.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index d42dd16..a571437 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -698,7 +698,10 @@ static int icmpv6_rcv(struct sk_buff *skb)
 
 	switch (type) {
 	case ICMPV6_ECHO_REQUEST:
-		icmpv6_echo_reply(skb);
+		/* check that the query is not for loopback address (PSE SPB) */
+		if (!(ipv6_addr_type(daddr) & IPV6_ADDR_LOOPBACK) ||
+		    (dev->flags & IFF_LOOPBACK))
+			icmpv6_echo_reply(skb);
 		break;
 
 	case ICMPV6_ECHO_REPLY:


-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
