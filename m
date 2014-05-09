From: "Sergey V. Lobanov" <sergey@lobanov.in>
Subject: [PATCH iproute2] TBF man page fix (tbf is not classless)
Date: Fri,  9 May 2014 22:12:54 +0400
Message-ID: <1399659174-20841-1-git-send-email-sergey@lobanov.in>
Cc: "Sergey V. Lobanov" <sergey@lobanov.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward11.mail.yandex.net ([95.108.130.93]:59519 "EHLO
	forward11.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757150AbaEISTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 14:19:16 -0400
Received: from smtp14.mail.yandex.net (smtp14.mail.yandex.net [95.108.131.192])
	by forward11.mail.yandex.net (Yandex) with ESMTP id 04DDCE816F7
	for <netdev@vger.kernel.org>; Fri,  9 May 2014 22:12:59 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TBF is not classless qdisc. man page corrected, added example
describing the use of inner qdisc

Signed-off-by: Sergey V. Lobanov <sergey@lobanov.in>
---
 man/man8/tc-tbf.8 |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-tbf.8 b/man/man8/tc-tbf.8
index 370a537..18ef7b4 100644
--- a/man/man8/tc-tbf.8
+++ b/man/man8/tc-tbf.8
@@ -21,7 +21,7 @@ bytes/cell
 burst is also known as buffer and maxburst. mtu is also known as minburst.
 .SH DESCRIPTION
 
-The Token Bucket Filter is a classless queueing discipline available for
+The Token Bucket Filter is a classful queueing discipline available for
 traffic control with the 
 .BR tc (8)
 command.
@@ -121,9 +121,17 @@ To attach a TBF with a sustained maximum rate of 0.5mbit/s, a peakrate of 1.0mbi
 a 5kilobyte buffer, with a pre-bucket queue size limit calculated so the TBF causes
 at most 70ms of latency, with perfect peakrate behaviour, issue:
 .P
-# tc qdisc add dev eth0 root tbf rate 0.5mbit \\
+# tc qdisc add dev eth0 handle 10: root tbf rate 0.5mbit \\
   burst 5kb latency 70ms peakrate 1mbit       \\
   minburst 1540
+.P
+To attach an inner qdisc, for example sfq, issue:
+.P
+# tc qdisc add dev eth0 parent 10:1 handle 100: sfq
+.P
+Without inner qdisc TBF queue acts as bfifo. If the inner qdisc is changed
+the limit/latency is not effective anymore.
+.P
 
 .SH SEE ALSO
 .BR tc (8)
-- 
1.7.9.5
