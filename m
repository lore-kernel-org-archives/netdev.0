From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: Fix state threshold configuration from userspace
Date: Thu, 22 Oct 2015 08:07:18 +0200
Message-ID: <1445494039-2612-4-git-send-email-steffen.klassert@secunet.com>
References: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50541 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbbJVGHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 02:07:30 -0400
In-Reply-To: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Rossberg <michael.rossberg@tu-ilmenau.de>

Allow to change the replay threshold (XFRMA_REPLAY_THRESH) and expiry
timer (XFRMA_ETIMER_THRESH) of a state without having to set other
attributes like replay counter and byte lifetime. Changing these other
values while traffic flows will break the state.

Signed-off-by: Michael Rossberg <michael.rossberg@tu-ilmenau.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a8de9e3..24e06a2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1928,8 +1928,10 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
 	struct nlattr *re = attrs[XFRMA_REPLAY_ESN_VAL];
 	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
+	struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
+	struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
 
-	if (!lt && !rp && !re)
+	if (!lt && !rp && !re && !et && !rt)
 		return err;
 
 	/* pedantic mode - thou shalt sayeth replaceth */
-- 
1.9.1
