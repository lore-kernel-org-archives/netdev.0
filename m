From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 2/2] RTO connection timeout: sysctl documentation update
Date: Tue, 01 Sep 2009 22:24:04 +0200
Message-ID: <4A9D82E4.6050709@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54558 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754277AbZIAUYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 16:24:08 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KPB0097C7BWNDB0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 01 Sep 2009 22:24:04 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n81KO4fG004394	for
 <netdev@vger.kernel.org>; Tue, 01 Sep 2009 22:24:04 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the sysctl documentation concerning the interpretation
of tcp_retries{1,2} and tcp_orphan_retries.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 Documentation/networking/ip-sysctl.txt |   37 ++++++++++++++++++++++---------
 1 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 8be7623..b6ee71f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -311,9 +311,12 @@ tcp_no_metrics_save - BOOLEAN
 	connections.
 
 tcp_orphan_retries - INTEGER
-	How may times to retry before killing TCP connection, closed
-	by our side. Default value 7 corresponds to ~50sec-16min
-	depending on RTO. If you machine is loaded WEB server,
+	This value influences the timeout of a locally closed TCP connection,
+	when RTO retransmissions remain unacknowledged.
+	See tcp_retries2 for more details.
+
+	The default value is 7.
+	If your machine is a loaded WEB server,
 	you should think about lowering this value, such sockets
 	may consume significant resources. Cf. tcp_max_orphans.
 
@@ -327,16 +330,28 @@ tcp_retrans_collapse - BOOLEAN
 	certain TCP stacks.
 
 tcp_retries1 - INTEGER
-	How many times to retry before deciding that something is wrong
-	and it is necessary to report this suspicion to network layer.
-	Minimal RFC value is 3, it is default, which corresponds
-	to ~3sec-8min depending on RTO.
+	This value influences the time, after which TCP decides, that
+	something is wrong due to unacknowledged RTO retransmissions,
+	and reports this suspicion to the network layer.
+	See tcp_retries2 for more details.
+
+	RFC 1122 recommends at least 3 retransmissions, which is the
+	default.
 
 tcp_retries2 - INTEGER
-	How may times to retry before killing alive TCP connection.
-	RFC1122 says that the limit should be longer than 100 sec.
-	It is too small number.	Default value 15 corresponds to ~13-30min
-	depending on RTO.
+	This value influences the timeout of an alive TCP connection,
+	when RTO retransmissions remain unacknowledged.
+	Given a value of N, a hypothetical TCP connection following
+	exponential backoff with an initial RTO of TCP_RTO_MIN would
+	retransmit N times before killing the connection at the (N+1)th RTO.
+
+	The default value of 15 yields a hypothetical timeout of 924.6
+	seconds and is a lower bound for the effective timeout.
+	TCP will effectively time out at the first RTO which exceeds the
+	hypothetical timeout.
+
+	RFC 1122 recommends at least 100 seconds for the timeout,
+	which corresponds to a value of at least 8.
 
 tcp_rfc1337 - BOOLEAN
 	If set, the TCP stack behaves conforming to RFC1337. If unset,
-- 
1.6.3.3

