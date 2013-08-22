From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/6] xfrm: Make xfrm_state timer monotonic
Date: Thu, 22 Aug 2013 13:12:09 +0200
Message-ID: <1377169931-7302-6-git-send-email-steffen.klassert@secunet.com>
References: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51125 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289Ab3HVLMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:12:37 -0400
In-Reply-To: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

xfrm_state timer should be independent of system clock change,
so switch to CLOCK_BOOTTIME base which is not only monotonic but
also counting suspend time.

Thus issue reported in commit: 9e0d57fd6dad37d72a3ca6db00ca8c76f2215454
("xfrm: SAD entries do not expire correctly after suspend-resume")
could ALSO be avoided.

v2: Use CLOCK_BOOTTIME to count suspend time, but still monotonic.

Signed-off-by: Fan Du <fan.du@windriver.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b2cd806..4f8ace8 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -499,7 +499,8 @@ struct xfrm_state *xfrm_state_alloc(struct net *net)
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
