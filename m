From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPv6][IPsec] fix the address family for xfrm_state_lookup
 in xfrm_input
Date: Tue, 4 Dec 2007 14:28:36 +0900
Message-ID: <20071204142836.a864e30e.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:42704 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbXLDF2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 00:28:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert, 

This is the patch to fix IPv6 IPsec input.

Signed-off-by: Kazunori MIYAZAWA <kazunori@miyazawa.org>
---
 net/xfrm/xfrm_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 96f42c1..da3c963 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -136,7 +136,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		if (skb->sp->len == XFRM_MAX_DEPTH)
 			goto drop;
 
-		x = xfrm_state_lookup(daddr, spi, nexthdr, AF_INET);
+		x = xfrm_state_lookup(daddr, spi, nexthdr, skb->dst->ops->family);
 		if (x == NULL)
 			goto drop;
 
-- 
1.4.4.2

