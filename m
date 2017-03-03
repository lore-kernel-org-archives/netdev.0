From: trajaraman@mvista.com
Subject: [xfrm] xfrm: Added the auth and enc update support in "state update"
Date: Fri,  3 Mar 2017 15:53:39 +0530
Message-ID: <1488536619-14363-1-git-send-email-trajaraman@mvista.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiruvadi rajaraman <trajaraman@mvista.com>
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34397 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751394AbdCCKYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 05:24:44 -0500
Received: by mail-pg0-f54.google.com with SMTP id 16so8453575pga.1
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 02:23:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thiruvadi rajaraman <trajaraman@mvista.com>

Updated the xfrm state update process to update the
Authendication and Encryption keys.

Signed-off-by: Thiruvadi rajaraman <trajaraman@mvista.com>
---
 net/xfrm/xfrm_state.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 419bf5d..6b15447 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1388,6 +1388,12 @@ int xfrm_state_update(struct xfrm_state *x)
 		memcpy(&x1->lft, &x->lft, sizeof(x1->lft));
 		x1->km.dying = 0;
 
+		/* To update Authendication and Encryption keys */
+		x1->aalg = kmemdup(x->aalg, xfrm_alg_auth_len(x->aalg),
+								GFP_KERNEL);
+		x1->ealg = kmemdup(x->ealg, xfrm_alg_len(x->ealg),
+								GFP_KERNEL);
+
 		tasklet_hrtimer_start(&x1->mtimer, ktime_set(1, 0), HRTIMER_MODE_REL);
 		if (x1->curlft.use_time)
 			xfrm_state_check_expire(x1);
-- 
1.9.1
