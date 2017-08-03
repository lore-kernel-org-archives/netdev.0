From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc-simple: Fix documentation
Date: Thu,  3 Aug 2017 17:00:51 +0200
Message-ID: <20170803150051.19741-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53979 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751158AbdHCPBD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 11:01:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- CONTROL has to come last, otherwise 'index' applies to gact and not
  simple itself.
- Man page wasn't updated to reflect syntax changes.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-simple.8 | 29 ++++++++++++++++++++++++++---
 tc/m_simple.c        |  4 ++--
 2 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/man/man8/tc-simple.8 b/man/man8/tc-simple.8
index 2206dc3b88614..7363ab563e189 100644
--- a/man/man8/tc-simple.8
+++ b/man/man8/tc-simple.8
@@ -6,15 +6,37 @@ simple - basic example action
 .in +8
 .ti -8
 .BR tc " ... " "action simple"
-.I STRING
+[
+.BI sdata " STRING"
+] [
+.BI index " INDEX"
+] [
+.I CONTROL
+]
+
+.ti -8
+.IR CONTROL " := {"
+.BR reclassify " | " pipe " | " drop " | " continue " | " ok " }"
+
 .SH DESCRIPTION
 This is a pedagogical example rather than an actually useful action. Upon every access, it prints the given
 .I STRING
 which may be of arbitrary length.
 .SH OPTIONS
 .TP
-.I STRING
+.BI sdata " STRING"
 The actual string to print.
+.TP
+.BI index " INDEX"
+Optional action index value.
+.TP
+.I CONTROL
+Indicate how
+.B tc
+should proceed after executing the action. For a description of the possible
+.I CONTROL
+values, see
+.BR tc-actions (8).
 .SH EXAMPLES
 The following example makes the kernel yell "Incoming ICMP!" every time it sees
 an incoming ICMP on eth0. Steps are:
@@ -36,7 +58,7 @@ display stats again and observe increment by 1
 .EX
   hadi@noma1:$ tc qdisc add dev eth0 ingress
   hadi@noma1:$tc filter add dev eth0 parent ffff: protocol ip prio 5 \\
-	 u32 match ip protocol 1 0xff flowid 1:1 action simple "Incoming ICMP"
+	 u32 match ip protocol 1 0xff flowid 1:1 action simple sdata "Incoming ICMP"
 
   hadi@noma1:$ sudo tc -s filter ls  dev eth0 parent ffff:
    filter protocol ip pref 5 u32
@@ -74,3 +96,4 @@ display stats again and observe increment by 1
 .EE
 .SH SEE ALSO
 .BR tc (8)
+.BR tc-actions (8)
diff --git a/tc/m_simple.c b/tc/m_simple.c
index a4457c70324ee..800cf7d703be6 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -81,10 +81,10 @@
 #endif
 static void explain(void)
 {
-	fprintf(stderr, "Usage:... simple [sdata STRING] [CONTROL] [index INDEX]\n");
+	fprintf(stderr, "Usage:... simple [sdata STRING] [index INDEX] [CONTROL]\n");
 	fprintf(stderr, "\tSTRING being an arbitrary string\n"
-		"\tCONTROL := reclassify|pipe|drop|continue|ok\n"
 		"\tINDEX := optional index value used\n");
+		"\tCONTROL := reclassify|pipe|drop|continue|ok\n"
 }
 
 static void usage(void)
-- 
2.13.1
