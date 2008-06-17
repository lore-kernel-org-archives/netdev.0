From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix econet open-coded sock_orphan().
Date: Tue, 17 Jun 2008 03:03:32 -0700 (PDT)
Message-ID: <20080617.030332.176445772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751353AbYFQKDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 06:03:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CDABBC8C18D
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 03:03:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Speaking of orphans, AF_ECONET might be a good candidate for
the deprecation schedule.  It has no listed maintainer and
no known users.

Anyways, applied and pushed to net-next-2.6

econet: Use sock_orphan() instead of open-coded (and buggy) variant.

It doesn't grab the sk_callback_lock, it doesn't NULL out
the sk->sk_sleep waitqueue pointer, etc.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/econet/af_econet.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 7c9bb13..d35127b 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -573,9 +573,7 @@ static int econet_release(struct socket *sock)
 
 	sk->sk_state_change(sk);	/* It is useless. Just for sanity. */
 
-	sock->sk = NULL;
-	sk->sk_socket = NULL;
-	sock_set_flag(sk, SOCK_DEAD);
+	sock_orphan(sk);
 
 	/* Purge queues */
 
-- 
1.5.5.1.308.g1fbb5

