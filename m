From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 17/18] ss: Make sstate_namel local to scan_state()
Date: Fri,  2 Dec 2016 11:40:01 +0100
Message-ID: <20161202104002.17310-18-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48527 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933891AbcLBKlz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:55 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 8439f473d7f7b..c72aba7e65ad3 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -666,21 +666,6 @@ static const char *sctp_sstate_name[] = {
 	[SCTP_STATE_SHUTDOWN_ACK_SENT] = "ACK_SENT",
 };
 
-static const char *sstate_namel[] = {
-	"UNKNOWN",
-	[SS_ESTABLISHED] = "established",
-	[SS_SYN_SENT] = "syn-sent",
-	[SS_SYN_RECV] = "syn-recv",
-	[SS_FIN_WAIT1] = "fin-wait-1",
-	[SS_FIN_WAIT2] = "fin-wait-2",
-	[SS_TIME_WAIT] = "time-wait",
-	[SS_CLOSE] = "unconnected",
-	[SS_CLOSE_WAIT] = "close-wait",
-	[SS_LAST_ACK] = "last-ack",
-	[SS_LISTEN] =	"listening",
-	[SS_CLOSING] = "closing",
-};
-
 struct sockstat {
 	struct sockstat	   *next;
 	unsigned int	    type;
@@ -3888,6 +3873,20 @@ static void usage(void)
 
 static int scan_state(const char *state)
 {
+	static const char * const sstate_namel[] = {
+		"UNKNOWN",
+		[SS_ESTABLISHED] = "established",
+		[SS_SYN_SENT] = "syn-sent",
+		[SS_SYN_RECV] = "syn-recv",
+		[SS_FIN_WAIT1] = "fin-wait-1",
+		[SS_FIN_WAIT2] = "fin-wait-2",
+		[SS_TIME_WAIT] = "time-wait",
+		[SS_CLOSE] = "unconnected",
+		[SS_CLOSE_WAIT] = "close-wait",
+		[SS_LAST_ACK] = "last-ack",
+		[SS_LISTEN] =	"listening",
+		[SS_CLOSING] = "closing",
+	};
 	int i;
 
 	if (strcasecmp(state, "close") == 0 ||
-- 
2.10.0
