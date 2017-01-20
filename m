From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH iproute2 net-next v2] tc: m_csum: add support for SCTP checksum
Date: Fri, 20 Jan 2017 11:10:10 +0100
Message-ID: <7e8e15a6e6f11133b4e22166d27d32ad8d5a83e7.1484906832.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
        Gregoire Baron <baronchon@n7mm.org>,
        Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42024 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751859AbdATKRp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 05:17:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'sctp' parameter can now be used as 'csum' target to enable CRC32c
computation on SCTP packets.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---

Notes:
    V2
    - update man/man8/tc-csum.8 to include 'sctp' target

 man/man8/tc-csum.8 |  7 +++++--
 tc/m_csum.c        | 11 ++++++++---
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/man/man8/tc-csum.8 b/man/man8/tc-csum.8
index 3a64c82..f4392a4 100644
--- a/man/man8/tc-csum.8
+++ b/man/man8/tc-csum.8
@@ -19,6 +19,7 @@ csum - checksum update action
 .BR tcp " |"
 .BR udp " |"
 .BR udplite " |"
+.BR sctp " |"
 .IR SWEETS " }"
 
 .ti -8
@@ -43,9 +44,11 @@ IGMP header
 TCP header
 .RB ( tcp ),
 UDP header
-.RB ( udp ") or"
+.RB ( udp ),
 UDPLite header
-.RB ( udplite ).
+.RB ( udplite ") or"
+SCTP header
+.RB ( sctp ).
 .TP
 .B SWEETS
 These are merely syntactic sugar and ignored internally.
diff --git a/tc/m_csum.c b/tc/m_csum.c
index d5b1af6..0ee8cad 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -24,7 +24,7 @@ explain(void)
 {
 	fprintf(stderr, "Usage: ... csum <UPDATE>\n"
 			"Where: UPDATE := <TARGET> [<UPDATE>]\n"
-			"       TARGET := { ip4h | icmp | igmp | tcp | udp | udplite | <SWEETS> }\n"
+			"       TARGET := { ip4h | icmp | igmp | tcp | udp | udplite | sctp | <SWEETS> }\n"
 			"       SWEETS := { and | or | \'+\' }\n");
 }
 
@@ -65,6 +65,9 @@ parse_csum_args(int *argc_p, char ***argv_p, struct tc_csum *sel)
 		else if (matches(*argv, "udplite") == 0)
 			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_UDPLITE;
 
+		else if (matches(*argv, "sctp") == 0)
+			sel->update_flags |= TCA_CSUM_UPDATE_FLAG_SCTP;
+
 		else if ((matches(*argv, "and") == 0) ||
 			 (matches(*argv, "or") == 0) ||
 			 (matches(*argv, "+") == 0))
@@ -160,6 +163,7 @@ print_csum(struct action_util *au, FILE *f, struct rtattr *arg)
 	char *uflag_4 = "";
 	char *uflag_5 = "";
 	char *uflag_6 = "";
+	char *uflag_7 = "";
 
 	int uflag_count = 0;
 
@@ -191,13 +195,14 @@ print_csum(struct action_util *au, FILE *f, struct rtattr *arg)
 	CSUM_UFLAG_BUFFER(uflag_4, TCA_CSUM_UPDATE_FLAG_TCP, "tcp");
 	CSUM_UFLAG_BUFFER(uflag_5, TCA_CSUM_UPDATE_FLAG_UDP, "udp");
 	CSUM_UFLAG_BUFFER(uflag_6, TCA_CSUM_UPDATE_FLAG_UDPLITE, "udplite");
+	CSUM_UFLAG_BUFFER(uflag_7, TCA_CSUM_UPDATE_FLAG_SCTP, "sctp");
 	if (!uflag_count) {
 		uflag_1 = "?empty";
 	}
 
-	fprintf(f, "csum (%s%s%s%s%s%s) action %s\n",
+	fprintf(f, "csum (%s%s%s%s%s%s%s) action %s\n",
 		uflag_1, uflag_2, uflag_3,
-		uflag_4, uflag_5, uflag_6,
+		uflag_4, uflag_5, uflag_6, uflag_7,
 		action_n2a(sel->action));
 	fprintf(f, "\tindex %u ref %d bind %d", sel->index, sel->refcnt,
 		sel->bindcnt);
-- 
2.7.4
