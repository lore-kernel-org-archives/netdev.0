From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] xfrm: Force SA to be lookup again if SA in acquire state
Date: Mon, 23 Sep 2013 17:18:25 +0800
Message-ID: <1379927905-17289-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42087 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197Ab3IWJSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 05:18:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If SA is in the process of acquiring, which indicates this SA is more
promising and precise than the fall back option, i.e. using wild card
source address for searching less suitable SA.

So, here bail out, and try again.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b9c3f9e..e1373d5 100644
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
