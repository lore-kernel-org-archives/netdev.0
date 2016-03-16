From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/8] man: tc-mirred.8: Reword man page a bit, add generic mirror example
Date: Wed, 16 Mar 2016 22:56:20 +0100
Message-ID: <1458165384-900-5-git-send-email-phil@nwl.cc>
References: <1458165384-900-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44498 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411AbcCPV5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 17:57:08 -0400
In-Reply-To: <1458165384-900-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-mirred.8 | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/man/man8/tc-mirred.8 b/man/man8/tc-mirred.8
index 52d98bc416563..bba96e0e5d8c0 100644
--- a/man/man8/tc-mirred.8
+++ b/man/man8/tc-mirred.8
@@ -21,11 +21,9 @@ mirred - mirror/redirect action
 .SH DESCRIPTION
 The
 .B mirred
-action allows to redirect or mirror packets to another network interface on the
-same system. It is typically used in combination with the
-.B ifb
-pseudo device to create a shrared instance where QoS happens, but serves well
-for debugging or monitoring purposes, too.
+action allows packet mirroring (copying) or redirecting (stealing) the packet it
+receives. Mirroring is what is sometimes referred to as Switch Port Analyzer
+(SPAN) and is commonly used to analyze and/or debug flows.
 .SH OPTIONS
 .TP
 .B ingress
@@ -67,9 +65,23 @@ debugging purposes:
 .EE
 .RE
 
-Use an
+Mirror all incoming ICMP packets on eth0 to a dummy interface for examination
+with e.g. tcpdump:
+
+.RS
+.EX
+# ip link add dummy0 type dummy
+# ip link set dummy0 up
+# tc qdisc add dev eth0 handle ffff: ingress
+# tc filter add dev eth0 parent ffff: protocol ip \\
+	u32 match ip protocol 1 0xff \\
+	action mirred egress mirror dev dummy0
+.EE
+.RE
+
+Using an
 .B ifb
-interface to send ingress traffic on eth0 through an instance of
+interface, it is possible to send ingress traffic through an instance of
 .BR sfq :
 
 .RS
-- 
2.7.2
