From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] tc-red: update man page
Date: Tue, 24 Jan 2012 14:18:33 +0100
Message-ID: <1327411113.7231.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52130 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab2AXNSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 08:18:37 -0500
Received: by wgbed3 with SMTP id ed3so3993496wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 05:18:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include documentation for harddrop and adaptive parameters.

All parameters but limit and avpkt are optional.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 man/man8/tc-red.8 |   52 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 41 insertions(+), 11 deletions(-)

diff --git a/man/man8/tc-red.8 b/man/man8/tc-red.8
index 32a47b8..f410d15 100644
--- a/man/man8/tc-red.8
+++ b/man/man8/tc-red.8
@@ -5,18 +5,19 @@ red \- Random Early Detection
 .B tc qdisc ... red
 .B limit 
 bytes
-.B min 
+.B [ min 
 bytes 
-.B max 
+.B ] [ max 
 bytes 
-.B avpkt
+.B ] avpkt
 bytes
-.B burst 
+.B [ burst 
 packets
-.B [ ecn ] [ bandwidth
+.B ] [ ecn ] [ harddrop] [ bandwidth
 rate
-.B ] probability
+.B ] [ probability
 chance
+.B ] [ adaptive ]
 
 .SH DESCRIPTION
 Random Early Detection is a classless qdisc which manages its queue size
@@ -66,7 +67,10 @@ parameter is provided to set a hard maximum for the size of the queue.
 .SH PARAMETERS
 .TP 
 min
-Average queue size at which marking becomes a possibility.
+Average queue size at which marking becomes a possibility. Defaults to
+.B max
+/3
+
 .TP 
 max
 At this average queue size, the marking probability is maximal. Should be at
@@ -74,11 +78,14 @@ least twice
 .B min
 to prevent synchronous retransmits, higher for low 
 .B min.
+Default to 
+.B limit
+/4
 .TP 
 probability
 Maximum probability for marking, specified as a floating point
 number from 0.0 to 1.0. Suggested values are 0.01 or 0.02 (1 or 2%,
-respectively).
+respectively). Default : 0.02
 .TP 
 limit
 Hard limit on the real (not average) queue size in bytes. Further packets
@@ -99,7 +106,7 @@ average queue size calculations. 1000 is a good value.
 bandwidth
 This rate is used for calculating the average queue size after some
 idle time. Should be set to the bandwidth of your interface. Does not mean
-that RED will shape for you! Optional.
+that RED will shape for you! Optional. Default : 10Mbit
 .TP
 ecn
 As mentioned before, RED can either 'mark' or 'drop'. Explicit Congestion
@@ -109,7 +116,26 @@ dropping a packet.  If this parameter is specified, packets which indicate
 that their hosts honor ECN will only be marked and not dropped, unless the
 queue size hits
 .B limit
-bytes. Needs a tc binary with RED support compiled in. Recommended.
+bytes. Recommended.
+.TP
+harddrop
+If average flow queue size is above
+.B max
+bytes, this parameter forces a drop instead of ecn marking.
+.TP
+adaptive
+(Added in linux-3.3) Sets RED in adaptive mode as described in http://icir.org/floyd/papers/adaptiveRed.pdf
+.nf
+Goal of Adaptive RED is to make 'probability' dynamic value between 1% and 50% to reach the target average queue : 
+.B (max - min) / 2
+.fi
+
+.SH EXAMPLE
+
+.P
+# tc qdisc add dev eth0 parent 1:1 handle 10: red 
+ limit 400000 min 30000 max 90000 avpkt 1000 
+ burst 55 ecn adaptive bandwidth 10Mbit
 
 .SH SEE ALSO
 .BR tc (8),
@@ -123,10 +149,14 @@ Congestion Avoidance. http://www.aciri.org/floyd/papers/red/red.html
 .TP 
 o
 Some changes to the algorithm by Alexey N. Kuznetsov.
+.TP
+o
+Adaptive RED  : http://icir.org/floyd/papers/adaptiveRed.pdf
 
 .SH AUTHORS
 Alexey N. Kuznetsov, <kuznet@ms2.inr.ac.ru>,  Alexey Makarenko
-<makar@phoenix.kharkov.ua>, J Hadi Salim <hadi@nortelnetworks.com>.  
+<makar@phoenix.kharkov.ua>, J Hadi Salim <hadi@nortelnetworks.com>,
+Eric Dumazet <eric.dumazet@gmail.com>.  
 This manpage maintained by bert hubert <ahu@ds9a.nl>
 
 
