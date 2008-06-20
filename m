From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp: /proc/net/tcp rto,ato values not scaled properly
Date: Fri, 20 Jun 2008 11:56:03 -0700
Message-ID: <20080620115603.5c494cab@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40030 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbYFTS4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 14:56:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found another case where we are sending information to userspace
in the wrong HZ scale.  This should have been fixed back in 2.5 :-(

This means an ABI change but as it stands there is no way for an application
like ss to get the right value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/tcp_ipv4.c	2008-06-20 11:44:10.000000000 -0700
+++ b/net/ipv4/tcp_ipv4.c	2008-06-20 11:46:35.000000000 -0700
@@ -2201,8 +2201,8 @@ static void get_tcp4_sock(struct sock *s
 		icsk->icsk_probes_out,
 		sock_i_ino(sk),
 		atomic_read(&sk->sk_refcnt), sk,
-		icsk->icsk_rto,
-		icsk->icsk_ack.ato,
+		jiffies_to_clock_t(icsk->icsk_rto),
+		jiffies_to_clock_t(icsk->icsk_ack.ato),
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		tp->snd_cwnd,
 		tp->snd_ssthresh >= 0xFFFF ? -1 : tp->snd_ssthresh,
--- a/net/ipv6/tcp_ipv6.c	2008-06-20 11:46:48.000000000 -0700
+++ b/net/ipv6/tcp_ipv6.c	2008-06-20 11:47:10.000000000 -0700
@@ -1962,8 +1962,8 @@ static void get_tcp6_sock(struct seq_fil
 		   icsk->icsk_probes_out,
 		   sock_i_ino(sp),
 		   atomic_read(&sp->sk_refcnt), sp,
-		   icsk->icsk_rto,
-		   icsk->icsk_ack.ato,
+		   jiffies_to_clock_t(icsk->icsk_rto),
+		   jiffies_to_clock_t(icsk->icsk_ack.ato),
 		   (icsk->icsk_ack.quick << 1 ) | icsk->icsk_ack.pingpong,
 		   tp->snd_cwnd, tp->snd_ssthresh>=0xFFFF?-1:tp->snd_ssthresh
 		   );
