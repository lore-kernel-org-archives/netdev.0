From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] decnet: af_decnet: mark expected switch fall-throughs
Date: Mon, 16 Oct 2017 15:11:22 -0500
Message-ID: <20171016201122.GA29615@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/decnet/af_decnet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 73a0399..5d52f0c 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -634,10 +634,12 @@ static void dn_destroy_sock(struct sock *sk)
 		goto disc_reject;
 	case DN_RUN:
 		scp->state = DN_DI;
+		/* fall through */
 	case DN_DI:
 	case DN_DR:
 disc_reject:
 		dn_nsp_send_disc(sk, NSP_DISCINIT, 0, sk->sk_allocation);
+		/* fall through */
 	case DN_NC:
 	case DN_NR:
 	case DN_RJ:
@@ -651,6 +653,7 @@ static void dn_destroy_sock(struct sock *sk)
 		break;
 	default:
 		printk(KERN_DEBUG "DECnet: dn_destroy_sock passed socket in invalid state\n");
+		/* fall through */
 	case DN_O:
 		dn_stop_slow_timer(sk);
 
-- 
2.7.4
