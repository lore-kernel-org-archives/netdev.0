From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 1/2] net-next-2.6: SYN retransmits: Rename threshold variable
Date: Tue, 28 Sep 2010 21:45:44 +0200
Message-ID: <1285703144.7187.4.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:52216 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755152Ab0I1Tpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 15:45:45 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L9H0093A2W8YKA0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 28 Sep 2010 21:45:44 +0200 (CEST)
Received: from [192.168.0.131] ([unknown] [109.91.208.56])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L9H00FXA2W8JN60@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Tue, 28 Sep 2010 21:45:44 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This preparatory patch renames the threshold variable in
retransmits_timed_out() for proper code style.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 net/ipv4/tcp_timer.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index baea4a1..98cbc60 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -141,7 +141,7 @@ static bool retransmits_timed_out(struct sock *sk,
 				  unsigned int boundary,
 				  unsigned int timeout)
 {
-	unsigned int linear_backoff_thresh, start_ts;
+	unsigned int backoff_thresh, start_ts;
 
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
@@ -152,13 +152,13 @@ static bool retransmits_timed_out(struct sock *sk,
 		start_ts = tcp_sk(sk)->retrans_stamp;
 
 	if (likely(timeout == 0)) {
-		linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
+		backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
 
-		if (boundary <= linear_backoff_thresh)
+		if (boundary <= backoff_thresh)
 			timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
 		else
-			timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
-				(boundary - linear_backoff_thresh) * TCP_RTO_MAX;
+			timeout = ((2 << backoff_thresh) - 1) * TCP_RTO_MIN +
+				  (boundary - backoff_thresh) * TCP_RTO_MAX;
 	}
 	return (tcp_time_stamp - start_ts) >= timeout;
 }
-- 
1.7.2.2




