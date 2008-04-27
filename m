From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] result of csum_fold() is already 16bit, no need to cast
Date: Sun, 27 Apr 2008 06:27:30 +0100
Message-ID: <20080427052730.GQ5882@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39990 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbYD0F1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 01:27:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/ipv6/ip6mr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index c8c6e33..2de3c46 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -358,7 +358,7 @@ static int pim6_rcv(struct sk_buff *skb)
 	if (pim->type != ((PIM_VERSION << 4) | PIM_REGISTER) ||
 	    (pim->flags & PIM_NULL_REGISTER) ||
 	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 &&
-	     (u16)csum_fold(skb_checksum(skb, 0, skb->len, 0))))
+	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
 
 	/* check if the inner packet is destined to mcast group */
-- 
1.5.3.GIT

