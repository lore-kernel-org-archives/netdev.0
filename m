From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add LAST_ACK as a valid state for TSQ
Date: Fri, 13 Jul 2012 10:46:09 +0200
Message-ID: <1342169169.3265.8338.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36412 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419Ab2GMIqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 04:46:13 -0400
Received: by bkwj10 with SMTP id j10so2916335bkw.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 01:46:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Socket state LAST_ACK should allow TSQ to send additional frames,
or else we rely on incoming ACKS or timers to send them.

Reported-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
---
 net/ipv4/tcp_output.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 03854ab..15a7c7b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -838,7 +838,7 @@ static void tcp_tasklet_func(unsigned long data)
 		if (!sock_owned_by_user(sk)) {
 			if ((1 << sk->sk_state) &
 			    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
-			     TCPF_CLOSING | TCPF_CLOSE_WAIT))
+			     TCPF_CLOSING | TCPF_CLOSE_WAIT | TCPF_LAST_ACK))
 				tcp_write_xmit(sk,
 					       tcp_current_mss(sk),
 					       0, 0,
@@ -868,7 +868,7 @@ void tcp_release_cb(struct sock *sk)
 	if (test_and_clear_bit(TSQ_OWNED, &tp->tsq_flags)) {
 		if ((1 << sk->sk_state) &
 		    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
-		     TCPF_CLOSING | TCPF_CLOSE_WAIT))
+		     TCPF_CLOSING | TCPF_CLOSE_WAIT | TCPF_LAST_ACK))
 			tcp_write_xmit(sk,
 				       tcp_current_mss(sk),
 				       0, 0,
