From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 16/18] ss: Make sstate_name local to sock_state_print()
Date: Fri,  2 Dec 2016 11:40:00 +0100
Message-ID: <20161202104002.17310-17-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40205 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934264AbcLBKlt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:49 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index e82c416b5fa72..8439f473d7f7b 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -655,21 +655,6 @@ static unsigned long long cookie_sk_get(const uint32_t *cookie)
 	return (((unsigned long long)cookie[1] << 31) << 1) | cookie[0];
 }
 
-static const char *sstate_name[] = {
-	"UNKNOWN",
-	[SS_ESTABLISHED] = "ESTAB",
-	[SS_SYN_SENT] = "SYN-SENT",
-	[SS_SYN_RECV] = "SYN-RECV",
-	[SS_FIN_WAIT1] = "FIN-WAIT-1",
-	[SS_FIN_WAIT2] = "FIN-WAIT-2",
-	[SS_TIME_WAIT] = "TIME-WAIT",
-	[SS_CLOSE] = "UNCONN",
-	[SS_CLOSE_WAIT] = "CLOSE-WAIT",
-	[SS_LAST_ACK] = "LAST-ACK",
-	[SS_LISTEN] =	"LISTEN",
-	[SS_CLOSING] = "CLOSING",
-};
-
 static const char *sctp_sstate_name[] = {
 	[SCTP_STATE_CLOSED] = "CLOSED",
 	[SCTP_STATE_COOKIE_WAIT] = "COOKIE_WAIT",
@@ -815,6 +800,20 @@ static const char *proto_name(int protocol)
 static void sock_state_print(struct sockstat *s)
 {
 	const char *sock_name;
+	static const char * const sstate_name[] = {
+		"UNKNOWN",
+		[SS_ESTABLISHED] = "ESTAB",
+		[SS_SYN_SENT] = "SYN-SENT",
+		[SS_SYN_RECV] = "SYN-RECV",
+		[SS_FIN_WAIT1] = "FIN-WAIT-1",
+		[SS_FIN_WAIT2] = "FIN-WAIT-2",
+		[SS_TIME_WAIT] = "TIME-WAIT",
+		[SS_CLOSE] = "UNCONN",
+		[SS_CLOSE_WAIT] = "CLOSE-WAIT",
+		[SS_LAST_ACK] = "LAST-ACK",
+		[SS_LISTEN] =	"LISTEN",
+		[SS_CLOSING] = "CLOSING",
+	};
 
 	switch (s->local.family) {
 	case AF_UNIX:
-- 
2.10.0
