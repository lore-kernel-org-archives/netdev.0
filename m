From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: udp.c
Date: Tue, 14 Jun 2005 07:42:52 +1000
Message-ID: <E1Dhwho-0001mn-00@gondolin.me.apana.org.au>
References: <20050613.124515.104034144.davem@davemloft.net>
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261470AbVFMVr5@vger.kernel.org>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050613.124515.104034144.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> From: Jesper Juhl <jesper.juhl@gmail.com>
> Date: Mon, 13 Jun 2005 19:23:36 +0200
> 
>> Why not remove the function and audit the code for users (and if any,
>> remove them)...? Let's get rid of it instead of having a function sit
>> around the only purpose of which is to BUG();
> 
> Then if someone breaks that invariant, we'll never find out.
> 
> The code is staying, sorry.

It'll dump the stack anyway if we just make it a NULL pointer.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -201,11 +201,6 @@ fail:
 	return 1;
 }
 
-static void udp_v4_hash(struct sock *sk)
-{
-	BUG();
-}
-
 static void udp_v4_unhash(struct sock *sk)
 {
 	write_lock_bh(&udp_hash_lock);
@@ -1370,7 +1365,7 @@ struct proto udp_prot = {
 	.recvmsg =	udp_recvmsg,
 	.sendpage =	udp_sendpage,
 	.backlog_rcv =	udp_queue_rcv_skb,
-	.hash =		udp_v4_hash,
+	/* .hash is intentionally left NULL */
 	.unhash =	udp_v4_unhash,
 	.get_port =	udp_v4_get_port,
 	.obj_size =	sizeof(struct udp_sock),
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -135,11 +135,6 @@ fail:
 	return 1;
 }
 
-static void udp_v6_hash(struct sock *sk)
-{
-	BUG();
-}
-
 static void udp_v6_unhash(struct sock *sk)
 {
  	write_lock_bh(&udp_hash_lock);
@@ -1048,7 +1043,7 @@ struct proto udpv6_prot = {
 	.sendmsg =	udpv6_sendmsg,
 	.recvmsg =	udpv6_recvmsg,
 	.backlog_rcv =	udpv6_queue_rcv_skb,
-	.hash =		udp_v6_hash,
+	/* .hash is intentionally left NULL */
 	.unhash =	udp_v6_unhash,
 	.get_port =	udp_v6_get_port,
 	.obj_size =	sizeof(struct udp6_sock),
