From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 3/3][v2] tcp: fix ICMP-RTO war: Code beautification
Date: Fri, 29 Jan 2010 23:16:05 +0100
Message-ID: <4B635E25.8080502@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54557 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755703Ab0A2WQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 17:16:06 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KX10023L4ITPJE0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 29 Jan 2010 23:16:05 +0100 (CET)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id o0TMG5jl019970	for
 <netdev@vger.kernel.org>; Fri, 29 Jan 2010 23:16:05 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rearranged functions and removed function prototype.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ff6cbaa..2a9ced8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -528,7 +528,17 @@ static inline void tcp_bound_rto(const struct sock *sk)
 		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
 }
 
-static inline u32 tcp_rto_min(struct sock *sk);
+/* Compute the actual rto_min value */
+static inline u32 tcp_rto_min(struct sock *sk)
+{
+	struct dst_entry *dst = __sk_dst_get(sk);
+	u32 rto_min = TCP_RTO_MIN;
+
+	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
+		rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
+	return rto_min;
+}
+
 static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 {
 	u32 rto = (tp->srtt >> 3) + tp->rttvar;
@@ -559,17 +569,6 @@ static inline void tcp_fast_path_check(struct sock *sk)
 		tcp_fast_path_on(tp);
 }
 
-/* Compute the actual rto_min value */
-static inline u32 tcp_rto_min(struct sock *sk)
-{
-	struct dst_entry *dst = __sk_dst_get(sk);
-	u32 rto_min = TCP_RTO_MIN;
-
-	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
-		rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
-	return rto_min;
-}
-
 /* Compute the actual receive window we are currently advertising.
  * Rcv_nxt can be after the window if our peer push more data
  * than the offered window.
-- 
1.6.4.4

