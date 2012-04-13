From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] tcp:Remove redundant code entering quickack mode
Date: Fri, 13 Apr 2012 16:23:59 -0700
Message-ID: <1334359439-10147-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:57992 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264Ab2DMXXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 19:23:23 -0400
Received: by pbcun15 with SMTP id un15so4130314pbc.19
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 16:23:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_enter_quickack_mode() already calls tcp_incr_quickack() and sets
icsk->icsk_ack.ato  to TCP_ATO_MIN. This patch removes the duplication.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/ipv4/tcp_input.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9944c1d..40c2039 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5734,8 +5734,6 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			 */
 			inet_csk_schedule_ack(sk);
 			icsk->icsk_ack.lrcvtime = tcp_time_stamp;
-			icsk->icsk_ack.ato	 = TCP_ATO_MIN;
-			tcp_incr_quickack(sk);
 			tcp_enter_quickack_mode(sk);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
-- 
1.7.0.4
