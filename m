From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: fix a race in xfrm_state_lookup_byspi
Date: Wed, 29 Apr 2015 08:42:44 +0800
Message-ID: <1430268164-19019-1-git-send-email-roy.qing.li@gmail.com>
Cc: fan.du@intel.com, steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60781 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031083AbbD2Amy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 20:42:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The returned xfrm_state should be hold before unlock xfrm_state_lock,
otherwise the returned xfrm_state maybe be released.

Fixes: c454997e6[{pktgen, xfrm} Introduce xfrm_state_lookup_byspi..]
Cc: Fan Du <fan.du@intel.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f5e39e3..96688cd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -927,8 +927,8 @@ struct xfrm_state *xfrm_state_lookup_byspi(struct net *net, __be32 spi,
 			x->id.spi != spi)
 			continue;
 
-		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 		xfrm_state_hold(x);
+		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 		return x;
 	}
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
-- 
2.1.0
