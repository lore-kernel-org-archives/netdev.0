From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] xfrm: Make xfrm_state timer monotonic
Date: Tue, 6 Aug 2013 14:57:05 +0800
Message-ID: <1375772225-19265-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48461 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab3HFG45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 02:56:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_state timer should be independent of system clock change,
so switch to monotonic clock base.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..e57ab07 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -499,7 +499,7 @@ struct xfrm_state *xfrm_state_alloc(struct net *net)
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
-		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_REALTIME, HRTIMER_MODE_ABS);
+		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
 				(unsigned long)x);
 		x->curlft.add_time = get_seconds();
-- 
1.7.9.5
