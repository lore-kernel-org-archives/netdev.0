From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix open-coded sock_orphan() in x25.
Date: Tue, 17 Jun 2008 03:06:46 -0700 (PDT)
Message-ID: <20080617.030646.266233676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, linux-hams@vger.kernel.org
To: eis@baty.hanse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54171
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751622AbYFQKGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 06:06:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is similar to the AF_ECONET patch I just posted.

Applied and pushed to net-next-2.6

x25: Use sock_orphan() instead of open-coded (and buggy) variant.

It doesn't grab the sk_callback_lock, it doesn't NULL out
the sk->sk_sleep waitqueue pointer, etc.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/x25/af_x25.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index bcb091f..7b1c6ef 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -612,8 +612,7 @@ static int x25_release(struct socket *sock)
 			break;
 	}
 
-	sock->sk	= NULL;
-	sk->sk_socket	= NULL;	/* Not used, but we should do this */
+	sock_orphan(sk);
 out:
 	return 0;
 }
-- 
1.5.5.1.308.g1fbb5

