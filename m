From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
Date: Thu, 15 Aug 2013 15:49:06 +0800
Message-ID: <1376552946-18967-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42742 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab3HOHtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 03:49:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_state timer should be independent of system clock change,
so switch to CLOCK_BOOTTIME base which is not only monotonic but
also counting suspend time.

Thus issue reported in commit: 9e0d57fd6dad37d72a3ca6db00ca8c76f2215454
("xfrm: SAD entries do not expire correctly after suspend-resume")
could ALSO be avoided.

Signed-off-by: Fan Du <fan.du@windriver.com>

v2: Use CLOCK_BOOTTIME to count suspend time, but still monotonic.

---
 net/xfrm/xfrm_state.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 79bf9a0..0824679 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -486,7 +486,8 @@ struct xfrm_state *xfrm_state_alloc(struct net *net)
 		INIT_HLIST_NODE(&x->bydst);
 		INIT_HLIST_NODE(&x->bysrc);
 		INIT_HLIST_NODE(&x->byspi);
-		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_REALTIME, HRTIMER_MODE_ABS);
+		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler,
+					CLOCK_BOOTTIME, HRTIMER_MODE_ABS);
 		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
 				(unsigned long)x);
 		x->curlft.add_time = get_seconds();
-- 
1.7.9.5
