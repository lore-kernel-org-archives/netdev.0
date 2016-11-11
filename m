From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 17/18] ss: Make sstate_namel local to scan_state()
Date: Fri, 11 Nov 2016 14:10:13 +0100
Message-ID: <20161111131014.21865-18-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37789 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932967AbcKKNMN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:12:13 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 14492da256c61..6e669f7b0593c 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -634,21 +634,6 @@ static unsigned long long cookie_sk_get(const uint32_t *cookie)
 	return (((unsigned long long)cookie[1] << 31) << 1) | cookie[0];
 }
 
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
@@ -3698,6 +3683,20 @@ static void usage(void)
 
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
