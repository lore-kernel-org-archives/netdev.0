From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 09/18] ss: Make tmr_name local to tcp_timer_print()
Date: Fri,  2 Dec 2016 11:39:53 +0100
Message-ID: <20161202104002.17310-10-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39923 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934104AbcLBKkc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:40:32 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's used only there, so no need to have it globally defined.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 71040a82ca6b1..97fcfd4a85548 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -882,15 +882,6 @@ static void sock_addr_print(const char *addr, char *delim, const char *port,
 	sock_addr_print_width(addr_width, addr, delim, serv_width, port, ifname);
 }
 
-static const char *tmr_name[] = {
-	"off",
-	"on",
-	"keepalive",
-	"timewait",
-	"persist",
-	"unknown"
-};
-
 static const char *print_ms_timer(int timeout)
 {
 	static char buf[64];
@@ -1983,6 +1974,15 @@ static void tcp_stats_print(struct tcpstat *s)
 
 static void tcp_timer_print(struct tcpstat *s)
 {
+	static const char * const tmr_name[] = {
+		"off",
+		"on",
+		"keepalive",
+		"timewait",
+		"persist",
+		"unknown"
+	};
+
 	if (s->timer) {
 		if (s->timer > 4)
 			s->timer = 5;
-- 
2.10.0
