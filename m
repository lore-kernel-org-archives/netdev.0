From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/8] tc: connmark, pedit: Rename BRANCH to CONTROL
Date: Tue, 22 Mar 2016 15:48:33 +0100
Message-ID: <1458658119-25881-3-git-send-email-phil@nwl.cc>
References: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60838 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758872AbcCVOtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:49:17 -0400
In-Reply-To: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Jamal suggested, BRANCH is the wrong name, as these keywords go
beyond simple branch control - e.g. loops are possible, too. Therefore
rename the non-terminal to CONTROL instead which should be more
appropriate.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-connmark.8 | 6 +++---
 man/man8/tc-pedit.8    | 6 +++---
 tc/m_connmark.c        | 4 ++--
 tc/m_pedit.c           | 4 ++--
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/man/man8/tc-connmark.8 b/man/man8/tc-connmark.8
index bb4cf7543dfdb..44f29f508d673 100644
--- a/man/man8/tc-connmark.8
+++ b/man/man8/tc-connmark.8
@@ -6,12 +6,12 @@ connmark - netfilter connmark retriever action
 .in +8
 .ti -8
 .BR tc " ... " "action connmark " [ " zone"
-.IR u16_zone_index " ] [ " BRANCH " ] ["
+.IR u16_zone_index " ] [ " CONTROL " ] ["
 .BI index " u32_index "
 ]
 
 .ti -8
-.IR BRANCH " := { " reclassify " | " pipe " | " drop " | " continue " | " ok " }"
+.IR CONTROL " := { " reclassify " | " pipe " | " drop " | " continue " | " ok " }"
 .SH DESCRIPTION
 The connmark action is used to restore the connection's mark value into the
 packet's fwmark.
@@ -22,7 +22,7 @@ Specify the conntrack zone when doing conntrack lookups for packets.
 .I u16_zone_index
 is a 16bit unsigned decimal value.
 .TP
-.I BRANCH
+.I CONTROL
 How to continue after executing this action.
 .RS
 .TP
diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index c30927ec50954..c34520c046a6c 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -6,7 +6,7 @@ pedit - generic packet editor action
 .in +8
 .ti -8
 .BR tc " ... " "action pedit munge " {
-.IR RAW_OP " | " LAYERED_OP " } [ " BRANCH " ]"
+.IR RAW_OP " | " LAYERED_OP " } [ " CONTROL " ]"
 
 .ti -8
 .IR RAW_OP " := "
@@ -45,7 +45,7 @@ pedit - generic packet editor action
 .IR RVAL " ]"
 
 .ti -8
-.IR BRANCH " := {"
+.IR CONTROL " := {"
 .BR reclassify " | " pipe " | " drop " | " shot " | " continue " | " pass " }"
 .SH DESCRIPTION
 The
@@ -165,7 +165,7 @@ This optional extra part of
 .I CMD_SPEC
 allows to exclude bits from being changed.
 .TP
-.I BRANCH
+.I CONTROL
 The following keywords allow to control how the tree of qdisc, classes,
 filters and actions is further traversed after this action.
 .RS
diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index 2414f321c1f8f..b1c7d3af54cc4 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -27,10 +27,10 @@
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: ... connmark [zone ZONE] [BRANCH] [index <INDEX>]\n");
+	fprintf(stderr, "Usage: ... connmark [zone ZONE] [CONTROL] [index <INDEX>]\n");
 	fprintf(stderr, "where :\n"
 		"\tZONE is the conntrack zone\n"
-		"\tBRANCH := reclassify|pipe|drop|continue|ok\n");
+		"\tCONTROL := reclassify|pipe|drop|continue|ok\n");
 }
 
 static void
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index ca78a83dd9d9d..9fe1a7ae3b90c 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -35,7 +35,7 @@ static int pedit_debug;
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: ... pedit munge <MUNGE> [<BRANCH>]\n");
+	fprintf(stderr, "Usage: ... pedit munge <MUNGE> [CONTROL]\n");
 	fprintf(stderr,
 		"Where: MUNGE := <RAW>|<LAYERED>\n"
 		"\t<RAW>:= <OFFSETC>[ATC]<CMD>\n \t\tOFFSETC:= offset <offval> <u8|u16|u32>\n "
@@ -43,7 +43,7 @@ explain(void)
 		"\t\tNOTE: maskval is a 32 bit hex number\n \t\tNOTE: shiftval is a is a shift value\n "
 		"\t\tCMD:= clear | invert | set <setval>| retain\n \t<LAYERED>:= ip <ipdata> | ip6 <ip6data> \n "
 		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>\n"
-		"\t<BRANCH>:= reclassify | pipe | drop | continue | pass\n"
+		"\tCONTROL:= reclassify | pipe | drop | continue | pass\n"
 		"For Example usage look at the examples directory\n");
 
 }
-- 
2.7.2
