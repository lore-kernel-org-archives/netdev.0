From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm: Force SA to be lookup again if SA in acquire state
Date: Fri, 18 Oct 2013 10:42:07 +0200
Message-ID: <1382085730-3415-2-git-send-email-steffen.klassert@secunet.com>
References: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51701 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753192Ab3JRImU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 04:42:20 -0400
In-Reply-To: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

If SA is in the process of acquiring, which indicates this SA is more
promising and precise than the fall back option, i.e. using wild card
source address for searching less suitable SA.

So, here bail out, and try again.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index d6e7f98..b2117a1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -815,7 +815,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 			xfrm_state_look_at(pol, x, fl, encap_family,
 					   &best, &acquire_in_progress, &error);
 	}
-	if (best)
+	if (best || acquire_in_progress)
 		goto found;
 
 	h_wildcard = xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, encap_family);
-- 
1.7.9.5
