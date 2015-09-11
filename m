From: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Subject: [PATCH] Net: core: stream.c: coding style fixes
Date: Fri, 11 Sep 2015 22:13:00 +0200
Message-ID: <1442002380-15526-1-git-send-email-cristos@vipserv.org>
Cc: edumazet@google.com, netdev@vger.kernel.org,
	Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sv1-2.x14.eu ([144.76.176.218]:48048 "EHLO sv1-2.x14.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbbIKUNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 16:13:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed coding style issues reported by checkpatch.pl

Signed-off-by: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
---
 net/core/stream.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/net/core/stream.c b/net/core/stream.c
index d70f77a..f169de8 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -7,9 +7,9 @@
  *     identical sendmsg() and recvmsg() code.
  *     So we (will) share it here.
  *
- *     Authors:        Arnaldo Carvalho de Melo <acme@conectiva.com.br>
- *                     (from old tcp.c code)
- *                     Alan Cox <alan@lxorguk.ukuu.org.uk> (Borrowed comments 8-))
+ *     Authors:    Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *                 (from old tcp.c code)
+ *                 Alan Cox <alan@lxorguk.ukuu.org.uk> (Borrowed comments 8-))
  */
 
 #include <linux/module.h>
@@ -60,6 +60,7 @@ int sk_stream_wait_connect(struct sock *sk, long *timeo_p)
 
 	do {
 		int err = sock_error(sk);
+
 		if (err)
 			return err;
 		if ((1 << sk->sk_state) & ~(TCPF_SYN_SENT | TCPF_SYN_RECV))
@@ -122,9 +123,10 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 	bool noblock = (*timeo_p ? false : true);
 	DEFINE_WAIT(wait);
 
-	if (sk_stream_memory_free(sk))
-		current_timeo = vm_wait = (prandom_u32() % (HZ / 5)) + 2;
-
+	if (sk_stream_memory_free(sk)) {
+		vm_wait = (prandom_u32() % (HZ / 5)) + 2;
+		current_timeo = vm_wait;
+	}
 	while (1) {
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
@@ -145,18 +147,19 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		sk->sk_write_pending++;
-		sk_wait_event(sk, &current_timeo, sk->sk_err ||
-						  (sk->sk_shutdown & SEND_SHUTDOWN) ||
-						  (sk_stream_memory_free(sk) &&
-						  !vm_wait));
+		sk_wait_event(sk, &current_timeo,
+			      sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN) ||
+			      (sk_stream_memory_free(sk) && !vm_wait));
 		sk->sk_write_pending--;
 
 		if (vm_wait) {
 			vm_wait -= current_timeo;
 			current_timeo = *timeo_p;
-			if (current_timeo != MAX_SCHEDULE_TIMEOUT &&
-			    (current_timeo -= vm_wait) < 0)
-				current_timeo = 0;
+			if (current_timeo != MAX_SCHEDULE_TIMEOUT) {
+				current_timeo -= vm_wait;
+				if (current_timeo < 0)
+					current_timeo = 0;
+			}
 			vm_wait = 0;
 		}
 		*timeo_p = current_timeo;
-- 
2.5.1
