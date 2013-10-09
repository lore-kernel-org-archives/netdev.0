From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/7] ipsec: Don't update the pmtu on ICMPV6_DEST_UNREACH
Date: Wed,  9 Oct 2013 12:59:07 +0200
Message-ID: <1381316351-14418-4-git-send-email-steffen.klassert@secunet.com>
References: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51345 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819Ab3JIK73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 06:59:29 -0400
In-Reply-To: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we update the pmtu in the IPsec protocol error handlers
if icmpv6 message type is either ICMPV6_DEST_UNREACH or
ICMPV6_PKT_TOOBIG. Updating the pmtu on ICMPV6_DEST_UNREACH
is wrong in any case, it causes strangely fragmented packets.
Only ICMPV6_PKT_TOOBIG signalizes pmtu discovery, so remove the
ICMPV6_DEST_UNREACH check in the IPsec protocol error handlers.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ah6.c     |    3 +--
 net/ipv6/esp6.c    |    3 +--
 net/ipv6/ipcomp6.c |    3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 73784c3..82e1da3 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -618,8 +618,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG &&
+	if (type != ICMPV6_PKT_TOOBIG &&
 	    type != NDISC_REDIRECT)
 		return;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d3618a7..e67e63f 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -436,8 +436,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG &&
+	if (type != ICMPV6_PKT_TOOBIG &&
 	    type != NDISC_REDIRECT)
 		return;
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 5636a91..ce507d9 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -64,8 +64,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		(struct ip_comp_hdr *)(skb->data + offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH &&
-	    type != ICMPV6_PKT_TOOBIG &&
+	if (type != ICMPV6_PKT_TOOBIG &&
 	    type != NDISC_REDIRECT)
 		return;
 
-- 
1.7.9.5
