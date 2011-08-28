From: Florian Westphal <fw@strlen.de>
Subject: [PATCH iproute2] tc: man: add man page for choke scheduler
Date: Sun, 28 Aug 2011 22:35:43 +0200
Message-ID: <1314563743-1655-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:55926 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752014Ab1H1Uh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 16:37:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/tc-red.8   |    3 +-
 man/man8/tc.8       |    1 +
 3 files changed, 65 insertions(+), 1 deletions(-)
 create mode 100644 man/man8/tc-choke.8

diff --git a/man/man8/tc-choke.8 b/man/man8/tc-choke.8
new file mode 100644
index 0000000..7b213be
--- /dev/null
+++ b/man/man8/tc-choke.8
@@ -0,0 +1,62 @@
+.TH TC 8 "August 2011" "iproute2" "Linux"
+.SH NAME
+choke \- choose and keep scheduler
+.SH SYNOPSIS
+.B tc qdisc ... choke
+.B limit
+bytes
+.B min
+bytes
+.B max
+bytes
+.B avpkt
+bytes
+.B burst
+packets
+.B [ ecn ] [ bandwidth
+rate
+.B ] probability
+chance
+
+.SH DESCRIPTION
+
+CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for unresponsive flows)
+is a classless qdisc designed to both identify and penalize flows that monopolize the
+queue.  CHOKe is a variation of RED, and the configuration is the same as RED.
+
+.SH ALGORITHM
+Once the queue hits a certain average length, a random packet is drawn from the
+queue.  If both the to-be-queued and the drawn packet belong to the same flow,
+both packets are dropped.  Otherwise, if the queue length is still below the maximum length,
+the new packet has a configurable chance of being marked (which may mean dropped).
+If the queue length exceeds
+.B max
+, the new packet will always be marked (or dropped).
+If the queue length exceeds
+.B limit
+, the new packet is always dropped.
+
+The marking probability computation is the same as used by the RED qdisc.
+
+.SH PARAMETERS
+The parameters are the same as for RED, see
+.BR tc-red (8)
+for a description.
+
+.SH SOURCE
+.TP
+o
+R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
+Active Queue Management Scheme for Approximating Fair Bandwidth Allocation",
+IEEE INFOCOM, 2000.
+.TP
+o
+A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and Spatial
+Characteristics", IEEE/ACM Transactions on Networking, 2004
+
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-red (8)
+
+.SH AUTHOR
+sched_choke was contributed by Stephen Hemminger.
diff --git a/man/man8/tc-red.8 b/man/man8/tc-red.8
index fa83675..32a47b8 100644
--- a/man/man8/tc-red.8
+++ b/man/man8/tc-red.8
@@ -112,7 +112,8 @@ queue size hits
 bytes. Needs a tc binary with RED support compiled in. Recommended.
 
 .SH SEE ALSO
-.BR tc (8)
+.BR tc (8),
+.BR tc-choke (8)
 
 .SH SOURCES
 .TP 
diff --git a/man/man8/tc.8 b/man/man8/tc.8
index e17ce68..bfc7f26 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -367,6 +367,7 @@ print rates in IEC units (ie. 1K = 1024).
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .SH SEE ALSO
 .BR tc-cbq (8),
+.BR tc-choke (8),
 .BR tc-drr (8),
 .BR tc-htb (8),
 .BR tc-sfq (8),
-- 
1.7.3.4
