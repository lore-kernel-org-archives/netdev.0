From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] xfrm: Simplify SA looking up when using wildcard source
Date: Fri, 18 Oct 2013 10:42:08 +0200
Message-ID: <1382085730-3415-3-git-send-email-steffen.klassert@secunet.com>
References: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51709 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011Ab3JRImV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 04:42:21 -0400
In-Reply-To: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

__xfrm4/6_state_addr_check is a four steps check, all we need to do
is checking whether the destination address match when looking SA
using wildcard source address. Passing saddr from flow is worst option,
as the checking needs to reach the fourth step while actually only
one time checking will do the work.

So, simplify this process by only checking destination address when
using wildcard source address for looking up SAs.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b2117a1..68c2f35 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -824,7 +824,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 		    x->props.reqid == tmpl->reqid &&
 		    (mark & x->mark.m) == x->mark.v &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
-		    xfrm_state_addr_check(x, daddr, saddr, encap_family) &&
+		    xfrm_addr_equal(&x->id.daddr, daddr, encap_family) &&
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
 		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi))
-- 
1.7.9.5
