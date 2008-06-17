From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Consolidate ax25 socket grafting.
Date: Tue, 17 Jun 2008 02:38:19 -0700 (PDT)
Message-ID: <20080617.023819.117125422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the netrom variant of the ax25 patch I just posted.

Applied and pushed to net-next-2.6

netrom: Use sock_graft() and remove bogus sk_socket and sk_sleep init.

This is the netrom variant of changeset
9375cb8a1232d2a15fe34bec4d3474872e02faec
("ax25: Use sock_graft() and remove bogus sk_socket and sk_sleep init.")

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netrom/af_netrom.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 4bae8b9..5877962 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -475,13 +475,11 @@ static struct sock *nr_make_new(struct sock *osk)
 	sock_init_data(NULL, sk);
 
 	sk->sk_type     = osk->sk_type;
-	sk->sk_socket   = osk->sk_socket;
 	sk->sk_priority = osk->sk_priority;
 	sk->sk_protocol = osk->sk_protocol;
 	sk->sk_rcvbuf   = osk->sk_rcvbuf;
 	sk->sk_sndbuf   = osk->sk_sndbuf;
 	sk->sk_state    = TCP_ESTABLISHED;
-	sk->sk_sleep    = osk->sk_sleep;
 	sock_copy_flags(sk, osk);
 
 	skb_queue_head_init(&nr->ack_queue);
@@ -810,13 +808,11 @@ static int nr_accept(struct socket *sock, struct socket *newsock, int flags)
 		goto out_release;
 
 	newsk = skb->sk;
-	newsk->sk_socket = newsock;
-	newsk->sk_sleep = &newsock->wait;
+	sock_graft(newsk, newsock);
 
 	/* Now attach up the new socket */
 	kfree_skb(skb);
 	sk_acceptq_removed(sk);
-	newsock->sk = newsk;
 
 out_release:
 	release_sock(sk);
-- 
1.5.5.1.308.g1fbb5

