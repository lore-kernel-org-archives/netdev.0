From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Wed,  6 Jan 2010 22:10:58 +0200
Message-ID: <1262808658-29346-1-git-send-email-opurdila@ixiacom.com>
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>,
	Maksim Pyatkovskiy <mpyatkovskiy@ixiacom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:1177 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755980Ab0AFUOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 15:14:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Maksim Pyatkovskiy <mpyatkovskiy@ixiacom.com>
Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/inet_connection_sock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ee16475..6c20043 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -23,6 +23,7 @@
 #include <net/route.h>
 #include <net/tcp_states.h>
 #include <net/xfrm.h>
+#include <net/tcp.h>
 
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
@@ -525,7 +526,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
 				int expire = 0, resend = 0;
+				struct net *net = sock_net(parent);
 
+				NET_INC_STATS_BH(net, LINUX_MIB_TCPTIMEOUTS);
 				syn_ack_recalc(req, thresh, max_retries,
 					       queue->rskq_defer_accept,
 					       &expire, &resend);
@@ -535,6 +538,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 				     inet_rsk(req)->acked)) {
 					unsigned long timeo;
 
+					TCP_INC_STATS_BH(net, TCP_MIB_RETRANSSEGS);
 					if (req->retrans++ == 0)
 						lopt->qlen_young--;
 					timeo = min((timeout << req->retrans), max_rto);
-- 
1.5.6.5

