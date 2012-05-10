From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/3] tcp: Out-line tcp_try_rmem_schedule
Date: Thu, 10 May 2012 15:50:20 +0400
Message-ID: <4FABAB7C.6040306@parallels.com>
References: <4FABAB39.6090201@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24160 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759191Ab2EJLu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 07:50:28 -0400
In-Reply-To: <4FABAB39.6090201@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As proposed by Eric, make the tcp_input.o thinner.

add/remove: 1/1 grow/shrink: 1/4 up/down: 868/-1329 (-461)
function                                     old     new   delta
tcp_try_rmem_schedule                          -     864    +864
tcp_ack                                     4811    4815      +4
tcp_validate_incoming                        817     815      -2
tcp_collapse                                 860     858      -2
tcp_send_rcvq                                555     353    -202
tcp_data_queue                              3435    3033    -402
tcp_prune_queue                              721       -    -721

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 164659f..b99ada2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4511,7 +4511,7 @@ static void tcp_ofo_queue(struct sock *sk)
 static int tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
-static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
+static int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
 {
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
 	    !sk_rmem_schedule(sk, size)) {
-- 
1.5.5.6
