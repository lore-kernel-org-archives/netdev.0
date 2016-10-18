From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] tcp: Remove unused but set variable
Date: Tue, 18 Oct 2016 11:22:54 +0200
Message-ID: <20161018092254.28043-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:53020 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934043AbcJRJXA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 05:23:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused but set variable icsk in listening_get_next to fix the
following GCC warning when building with 'W=1':

  net/ipv4/tcp_ipv4.c: In function ‘listening_get_next’:
  net/ipv4/tcp_ipv4.c:1890:31: warning: variable ‘icsk’ set but not used [-Wunused-but-set-variable]

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/ipv4/tcp_ipv4.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bd5e8d10893f..79d55eb3ec3f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1887,7 +1887,6 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 	struct inet_listen_hashbucket *ilb;
-	struct inet_connection_sock *icsk;
 	struct sock *sk = cur;
 
 	if (!sk) {
@@ -1909,7 +1908,6 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 			continue;
 		if (sk->sk_family == st->family)
 			return sk;
-		icsk = inet_csk(sk);
 	}
 	spin_unlock_bh(&ilb->lock);
 	st->offset = 0;
-- 
2.9.0
