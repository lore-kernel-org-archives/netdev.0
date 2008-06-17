From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Make LLC use sock_graft()
Date: Tue, 17 Jun 2008 01:22:50 -0700 (PDT)
Message-ID: <20080617.012250.172372648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbYFQIWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 04:22:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Applied and pushed out to net-next-2.6

llc: Use sock_graft() instead of by-hand version.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/llc/af_llc.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 97101dc..5bcc452 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -128,10 +128,8 @@ static int llc_ui_send_data(struct sock* sk, struct sk_buff *skb, int noblock)
 
 static void llc_ui_sk_init(struct socket *sock, struct sock *sk)
 {
+	sock_graft(sk, sock);
 	sk->sk_type	= sock->type;
-	sk->sk_sleep	= &sock->wait;
-	sk->sk_socket	= sock;
-	sock->sk	= sk;
 	sock->ops	= &llc_ui_ops;
 }
 
-- 
1.5.5.1.308.g1fbb5

