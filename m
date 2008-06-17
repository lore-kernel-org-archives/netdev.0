From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Kill spurious sk->sk_socket NULL assignments in netrom.
Date: Tue, 17 Jun 2008 03:24:09 -0700 (PDT)
Message-ID: <20080617.032409.216520881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751353AbYFQKYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 06:24:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Both of these assignments are spurious, so we can delete them.

Applied and pushed out to net-next-2.6

netrom: Kill spurious NULL'ing of sk->sk_socket.

In nr_release(), one code path calls sock_orphan() which
will NULL out sk->sk_socket already.

In the other case, handling states other than NR_STATE_{0,1,2,3},
seems to not be possible other than due to bugs.  Even for an
uninitialized nr->state value, that would be zero or NR_STATE_0.
It might be wise to stick a WARN_ON() here.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netrom/af_netrom.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 5877962..74884f4 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -536,11 +536,9 @@ static int nr_release(struct socket *sock)
 		sk->sk_state_change(sk);
 		sock_orphan(sk);
 		sock_set_flag(sk, SOCK_DESTROY);
-		sk->sk_socket   = NULL;
 		break;
 
 	default:
-		sk->sk_socket = NULL;
 		break;
 	}
 
-- 
1.5.5.1.308.g1fbb5

