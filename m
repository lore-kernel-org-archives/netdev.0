From: Joe Perches <joe@perches.com>
Subject: [PATCH 36/39] net/ipv4/tcp.c: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:53 -0700
Message-ID: <2afee732758b93d7464e6bb07a52b3bc67f164a4.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3809 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616Ab0J3VJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 17:09:50 -0400
In-Reply-To: <cover.1288471897.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coalesce long formats.
Align arguments.
Remove KERN_<level>.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/tcp.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1664a05..5f738c5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1193,7 +1193,7 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 	struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
 
 	WARN(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq),
-	     KERN_INFO "cleanup rbuf bug: copied %X seq %X rcvnxt %X\n",
+	     "cleanup rbuf bug: copied %X seq %X rcvnxt %X\n",
 	     tp->copied_seq, TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt);
 #endif
 
@@ -1477,10 +1477,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			 * shouldn't happen.
 			 */
 			if (WARN(before(*seq, TCP_SKB_CB(skb)->seq),
-			     KERN_INFO "recvmsg bug: copied %X "
-				       "seq %X rcvnxt %X fl %X\n", *seq,
-				       TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
-				       flags))
+				 "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
+				 *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
+				 flags))
 				break;
 
 			offset = *seq - TCP_SKB_CB(skb)->seq;
@@ -1490,10 +1489,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				goto found_ok_skb;
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
-			WARN(!(flags & MSG_PEEK), KERN_INFO "recvmsg bug 2: "
-					"copied %X seq %X rcvnxt %X fl %X\n",
-					*seq, TCP_SKB_CB(skb)->seq,
-					tp->rcv_nxt, flags);
+			WARN(!(flags & MSG_PEEK),
+			     "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
+			     *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
 		}
 
 		/* Well, if we have backlog, try to process it now yet. */
-- 
1.7.3.1.g432b3.dirty

