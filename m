From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 16/18] ss: Make sstate_name local to sock_state_print()
Date: Fri, 11 Nov 2016 14:10:12 +0100
Message-ID: <20161111131014.21865-17-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52111 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756416AbcKKNKo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:10:44 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index cf4187310816e..14492da256c61 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -634,21 +634,6 @@ static unsigned long long cookie_sk_get(const uint32_t *cookie)
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
 static const char *sstate_namel[] = {
 	"UNKNOWN",
 	[SS_ESTABLISHED] = "established",
@@ -769,6 +754,20 @@ static char *proto_name(int protocol)
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
