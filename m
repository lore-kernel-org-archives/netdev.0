From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] net/irda: remove pointless assignment/check
Date: Fri, 19 Aug 2016 18:08:57 +0200
Message-ID: <20160819160857.32254-1-vegard.nossum@oracle.com>
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
        Vegard Nossum <vegard.nossum@oracle.com>
To: Samuel Ortiz <samuel@sortiz.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34248 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752067AbcHSQLY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:11:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've already set sk to sock->sk and dereferenced it, so if it's NULL
we would have crashed already. Moreover, if it was NULL we would have
crashed anyway when jumping to 'out' and trying to unlock the sock.
Furthermore, if we had assigned a different value to 'sk' we would
have been calling lock_sock() and release_sock() on different sockets.

My conclusion is that these two lines are complete nonsense and only
serve to confuse the reader.

Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/irda/af_irda.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 8d2f7c9..db63969 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -845,9 +845,6 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 	if (sock->state != SS_UNCONNECTED)
 		goto out;
 
-	if ((sk = sock->sk) == NULL)
-		goto out;
-
 	err = -EOPNOTSUPP;
 	if ((sk->sk_type != SOCK_STREAM) && (sk->sk_type != SOCK_SEQPACKET) &&
 	    (sk->sk_type != SOCK_DGRAM))
-- 
2.10.0.rc0.1.g07c9292
