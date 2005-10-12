From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Timeline of IPoIB performance
Date: Wed, 12 Oct 2005 09:53:57 -0700
Message-ID: <52mzle7k2i.fsf@cisco.com>
References: <E1EPIxF-0001Cp-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1EPIxF-0001Cp-00@gondolin.me.apana.org.au> (Herbert Xu's
	message of "Tue, 11 Oct 2005 22:10:01 +1000")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Herbert> Try reverting the changeset

    Herbert> 314324121f9b94b2ca657a494cf2b9cb0e4a28cc

    Herbert> which lies between these two points and may be relevant.

Matt, I pulled this out of git for you.  I guess Herbert is suggesting
to patch -R the below against 2.6.12-rc5:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 79835a6..5bad504 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4355,16 +4355,7 @@ int tcp_rcv_established(struct sock *sk,
 					goto no_ack;
 			}
 
-			if (eaten) {
-				if (tcp_in_quickack_mode(tp)) {
-					tcp_send_ack(sk);
-				} else {
-					tcp_send_delayed_ack(sk);
-				}
-			} else {
-				__tcp_ack_snd_check(sk, 0);
-			}
-
+			__tcp_ack_snd_check(sk, 0);
 no_ack:
 			if (eaten)
 				__kfree_skb(skb);
