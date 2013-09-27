From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next] xfrm: Simplify SA looking up when using wildcard source
Date: Fri, 27 Sep 2013 16:32:50 +0800
Message-ID: <1380270770-19089-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47030 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab3I0Ic5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 04:32:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__xfrm4/6_state_addr_check is a four steps check, all we need to do
is checking whether the destination address match when looking SA
using wildcard source address. Passing saddr from flow is worst option,
as the checking needs to reach the fourth step while actually only
one time checking will do the work.

So, simplify this process by only checking destination address when
using wildcard source address for looking up SAs.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
v2:
  - Rewrite a good qualified commit log message 
  - Use xfrm_addr_equal instead of remaking wheel 
---
 net/xfrm/xfrm_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e1373d5..3fad928 100644
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
