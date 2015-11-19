From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/2] ppp: remove PPPOX_ZOMBIE socket state
Date: Thu, 19 Nov 2015 12:53:21 +0100
Message-ID: <d58f44d163d4f4176f331c22e3c22ac9caa501b3.1447931252.git.g.nault@alphalink.fr>
References: <cover.1447931252.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@earthlink.net>,
	Simon Farnsworth <simon@farnz.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42721 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757385AbbKSLxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 06:53:24 -0500
Content-Disposition: inline
In-Reply-To: <cover.1447931252.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPPOX_ZOMBIE is never set anymore.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/pppoe.c  | 4 ++--
 drivers/net/ppp/pppox.c  | 2 +-
 include/linux/if_pppox.h | 1 -
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 1dedfbf..277e682 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -311,7 +311,7 @@ static void pppoe_flush_dev(struct net_device *dev)
 			lock_sock(sk);
 
 			if (po->pppoe_dev == dev &&
-			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
+			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
 				pppox_unbind_sock(sk);
 				sk->sk_state_change(sk);
 				po->pppoe_dev = NULL;
@@ -775,7 +775,7 @@ static int pppoe_ioctl(struct socket *sock, unsigned int cmd,
 		struct pppox_sock *relay_po;
 
 		err = -EBUSY;
-		if (sk->sk_state & (PPPOX_BOUND | PPPOX_ZOMBIE | PPPOX_DEAD))
+		if (sk->sk_state & (PPPOX_BOUND | PPPOX_DEAD))
 			break;
 
 		err = -ENOTCONN;
diff --git a/drivers/net/ppp/pppox.c b/drivers/net/ppp/pppox.c
index 0e1b306..0200de7 100644
--- a/drivers/net/ppp/pppox.c
+++ b/drivers/net/ppp/pppox.c
@@ -58,7 +58,7 @@ void pppox_unbind_sock(struct sock *sk)
 {
 	/* Clear connection to ppp device, if attached. */
 
-	if (sk->sk_state & (PPPOX_BOUND | PPPOX_CONNECTED | PPPOX_ZOMBIE)) {
+	if (sk->sk_state & (PPPOX_BOUND | PPPOX_CONNECTED)) {
 		ppp_unregister_channel(&pppox_sk(sk)->chan);
 		sk->sk_state = PPPOX_DEAD;
 	}
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index b49cf92..ba7a9b0 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -91,7 +91,6 @@ enum {
     PPPOX_CONNECTED	= 1,  /* connection established ==TCP_ESTABLISHED */
     PPPOX_BOUND		= 2,  /* bound to ppp device */
     PPPOX_RELAY		= 4,  /* forwarding is enabled */
-    PPPOX_ZOMBIE	= 8,  /* dead, but still bound to ppp device */
     PPPOX_DEAD		= 16  /* dead, useless, please clean me up!*/
 };
 
-- 
2.6.2
