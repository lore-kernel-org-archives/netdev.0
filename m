From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 09/18] ss: Make tmr_name local to tcp_timer_print()
Date: Fri, 11 Nov 2016 14:10:05 +0100
Message-ID: <20161111131014.21865-10-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46229 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756412AbcKKNLs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:11:48 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's used only there, so no need to have it globally defined.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index e9fecd39a8493..477910a842726 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -830,15 +830,6 @@ static void sock_addr_print(const char *addr, char *delim, const char *port,
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
@@ -1879,6 +1870,15 @@ static void tcp_stats_print(struct tcpstat *s)
 
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
