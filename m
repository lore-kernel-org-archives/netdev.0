From: Yuvaraja Mariappan <ymariappan@gmail.com>
Subject: [PATCH 1/1] net: ipv4: tcp.c Fixed an assignment coding style issue
Date: Tue, 6 Oct 2015 11:08:54 -0700
Message-ID: <20151006180854.GA27181@ymariappan-mbp.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35862 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbbJFSIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 14:08:11 -0400
Received: by pablk4 with SMTP id lk4so216124269pab.3
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 11:08:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From beecc68c2ec1fecda34d26fcbc3c821e617b7bcb Mon Sep 17 00:00:00 2001
From: Yuvaraja Mariappan <ymariappan@gmail.com>
Date: Tue, 6 Oct 2015 10:53:29 -0700
Subject: [PATCH 1/1] net: ipv4: tcp.c Fixed an assignment coding style issue

Fixed an assignment coding style issue

Signed-off-by: Yuvaraja Mariappan <ymariappan@gmail.com>
---
 net/ipv4/tcp.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b8b8fa1..7d619d3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -900,7 +900,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	 */
 	if (((1 << sk->sk_state) & ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)) &&
 	    !tcp_passive_fastopen(sk)) {
-		if ((err = sk_stream_wait_connect(sk, &timeo)) != 0)
+		err = sk_stream_wait_connect(sk, &timeo);
+		if (err != 0)
 			goto out_err;
 	}
 
@@ -967,7 +968,8 @@ new_segment:
 
 		copied += copy;
 		offset += copy;
-		if (!(size -= copy)) {
+		size -= copy;
+		if (!size) {
 			tcp_tx_timestamp(sk, skb);
 			goto out;
 		}
@@ -988,7 +990,8 @@ wait_for_memory:
 		tcp_push(sk, flags & ~MSG_MORE, mss_now,
 			 TCP_NAGLE_PUSH, size_goal);
 
-		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
+		err = sk_stream_wait_memory(sk, &timeo);
+		if (err != 0)
 			goto do_error;
 
 		mss_now = tcp_send_mss(sk, &size_goal, flags);
@@ -1111,7 +1114,8 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	 */
 	if (((1 << sk->sk_state) & ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)) &&
 	    !tcp_passive_fastopen(sk)) {
-		if ((err = sk_stream_wait_connect(sk, &timeo)) != 0)
+		err = sk_stream_wait_connect(sk, &timeo);
+		if (err != 0)
 			goto do_error;
 	}
 
@@ -1267,7 +1271,8 @@ wait_for_memory:
 			tcp_push(sk, flags & ~MSG_MORE, mss_now,
 				 TCP_NAGLE_PUSH, size_goal);
 
-		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
+		err = sk_stream_wait_memory(sk, &timeo);
+		if (err != 0)
 			goto do_error;
 
 		mss_now = tcp_send_mss(sk, &size_goal, flags);
@@ -1767,7 +1772,8 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 
 			/* __ Restore normal policy in scheduler __ */
 
-			if ((chunk = len - tp->ucopy.len) != 0) {
+			chunk = len - tp->ucopy.len;
+			if (chunk != 0) {
 				NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMBACKLOG, chunk);
 				len -= chunk;
 				copied += chunk;
@@ -1778,7 +1784,8 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 do_prequeue:
 				tcp_prequeue_process(sk);
 
-				if ((chunk = len - tp->ucopy.len) != 0) {
+				chunk = len - tp->ucopy.len;
+				if (chunk != 0) {
 					NET_ADD_STATS_USER(sock_net(sk), LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE, chunk);
 					len -= chunk;
 					copied += chunk;
@@ -2230,7 +2237,8 @@ int tcp_disconnect(struct sock *sk, int flags)
 	sk->sk_shutdown = 0;
 	sock_reset_flag(sk, SOCK_DONE);
 	tp->srtt_us = 0;
-	if ((tp->write_seq += tp->max_window + 2) == 0)
+	tp->write_seq += tp->max_window + 2;
+	if (tp->write_seq == 0)
 		tp->write_seq = 1;
 	icsk->icsk_backoff = 0;
 	tp->snd_cwnd = 2;
-- 
1.9.1
