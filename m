From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH iproute2 net-next] tc: m_csum: add support for SCTP checksum
Date: Thu, 19 Jan 2017 18:26:42 +0100
Message-ID: <d979c4187228759f94c3b6c8504b16783e03bdc6.1484846369.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
        Gregoire Baron <baronchon@n7mm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49674 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753594AbdASRea (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 12:34:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'sctp' parameter can now be used as 'csum' target to enable CRC32c
computation on SCTP packets.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 tc/m_csum.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

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
