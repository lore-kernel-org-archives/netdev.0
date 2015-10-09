From: Richard Sailer <richard@weltraumpflege.org>
Subject: [PATCH net] tcp: change type of alive from int to bool
Date: Fri,  9 Oct 2015 02:41:37 +0200
Message-ID: <1444351297-22614-1-git-send-email-richard@weltraumpflege.org>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloster.rz.uni-augsburg.de ([137.250.2.98]:34949 "EHLO
	gloster.rz.uni-augsburg.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756051AbbJIAwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 20:52:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alive parameter of tcp_orphan_retries, indicates
whether the connection is assumed alive or not.
In the function and all places calling it is used as a boolean value.

Therefore this changes the type of alive to bool in the function
definition and all calling locations.

Since tcp_orphan_tries is a tcp_timer.c local function no change in
any other file or header is necessary.

Signed-off-by: Richard Sailer <richard@weltraumpflege.org>
---
 net/ipv4/tcp_timer.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 7149ebc..c9c716a 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -83,7 +83,7 @@ static int tcp_out_of_resources(struct sock *sk, bool do_reset)
 }
 
 /* Calculate maximal number or retries on an orphaned socket. */
-static int tcp_orphan_retries(struct sock *sk, int alive)
+static int tcp_orphan_retries(struct sock *sk, bool alive)
 {
 	int retries = sysctl_tcp_orphan_retries; /* May be zero. */
 
@@ -184,7 +184,7 @@ static int tcp_write_timeout(struct sock *sk)
 
 		retry_until = sysctl_tcp_retries2;
 		if (sock_flag(sk, SOCK_DEAD)) {
-			const int alive = icsk->icsk_rto < TCP_RTO_MAX;
+			const bool alive = icsk->icsk_rto < TCP_RTO_MAX;
 
 			retry_until = tcp_orphan_retries(sk, alive);
 			do_reset = alive ||
@@ -298,7 +298,7 @@ static void tcp_probe_timer(struct sock *sk)
 
 	max_probes = sysctl_tcp_retries2;
 	if (sock_flag(sk, SOCK_DEAD)) {
-		const int alive = inet_csk_rto_backoff(icsk, TCP_RTO_MAX) < TCP_RTO_MAX;
+		const bool alive = inet_csk_rto_backoff(icsk, TCP_RTO_MAX) < TCP_RTO_MAX;
 
 		max_probes = tcp_orphan_retries(sk, alive);
 		if (!alive && icsk->icsk_backoff >= max_probes)
-- 
2.5.3
