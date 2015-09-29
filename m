From: Michael Rossberg <michael.rossberg@tu-ilmenau.de>
Subject: [PATCH 1/1] xfrm: Fix state threshold configuration from userspace
Date: Tue, 29 Sep 2015 11:25:08 +0200
Message-ID: <1443518708-4397-1-git-send-email-michael.rossberg@tu-ilmenau.de>
Cc: netdev@vger.kernel.org, michael.rossberg@tu-ilmenau.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smail.rz.tu-ilmenau.de ([141.24.4.149]:42198 "EHLO
	smail.rz.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933283AbbI2JdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 05:33:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to change the replay threshold (XFRMA_REPLAY_THRESH) and expiry
timer (XFRMA_ETIMER_THRESH) of a state without having to set other
attributes like replay counter and byte lifetime. Changing these other
values while traffic flows will break the state.

Signed-off-by: Michael Rossberg <michael.rossberg@tu-ilmenau.de>
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
2.1.4
