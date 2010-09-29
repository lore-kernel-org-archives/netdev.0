From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] tcp: tcp_enter_quickack_mode can be static
Date: Wed, 29 Sep 2010 14:30:14 +0900
Message-ID: <20100929143014.7f32cec3@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58751 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903Ab0I2FaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 01:30:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function only used in tcp_input.c

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/tcp.h    |    2 --
 net/ipv4/tcp_input.c |    2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

--- a/net/ipv4/tcp_input.c	2010-09-29 14:00:54.145805254 +0900
+++ b/net/ipv4/tcp_input.c	2010-09-29 14:24:27.595831651 +0900
@@ -182,7 +182,7 @@ static void tcp_incr_quickack(struct soc
 		icsk->icsk_ack.quick = min(quickacks, TCP_MAX_QUICKACKS);
 }
 
-void tcp_enter_quickack_mode(struct sock *sk)
+static void tcp_enter_quickack_mode(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	tcp_incr_quickack(sk);
--- a/include/net/tcp.h	2010-09-29 14:27:53.543307029 +0900
+++ b/include/net/tcp.h	2010-09-29 14:28:10.435891279 +0900
@@ -346,8 +346,6 @@ static inline void tcp_dec_quickack_mode
 	}
 }
 
-extern void tcp_enter_quickack_mode(struct sock *sk);
-
 #define	TCP_ECN_OK		1
 #define	TCP_ECN_QUEUE_CWR	2
 #define	TCP_ECN_DEMAND_CWR	4
