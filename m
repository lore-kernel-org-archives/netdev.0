From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 1/6] ss: Make struct tcpstat fields 'timer' and 'timeout' unsigned
Date: Thu, 24 Aug 2017 11:41:26 +0200
Message-ID: <20170824094131.2963-2-phil@nwl.cc>
References: <20170824094131.2963-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45185 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751582AbdHXJlu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:41:50 -0400
In-Reply-To: <20170824094131.2963-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both 'timer' and 'timeout' variables of struct tcpstat are either
scanned as unsigned values from /proc/net/tcp{,6} or copied from
'idiag_timer' and 'idiag_expries' fields of struct inet_diag_msg, which
itself are unsigned. Therefore they may be unsigned as well, which
eliminates the need to check for negative values.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 34c6da5443642..c41d5169aba52 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -697,8 +697,8 @@ struct dctcpstat {
 
 struct tcpstat {
 	struct sockstat	    ss;
-	int		    timer;
-	int		    timeout;
+	unsigned int	    timer;
+	unsigned int	    timeout;
 	int		    probes;
 	char		    cong_alg[16];
 	double		    rto, ato, rtt, rttvar;
@@ -869,13 +869,11 @@ static void sock_addr_print(const char *addr, char *delim, const char *port,
 	sock_addr_print_width(addr_width, addr, delim, serv_width, port, ifname);
 }
 
-static const char *print_ms_timer(int timeout)
+static const char *print_ms_timer(unsigned int timeout)
 {
 	static char buf[64];
 	int secs, msecs, minutes;
 
-	if (timeout < 0)
-		timeout = 0;
 	secs = timeout/1000;
 	minutes = secs/60;
 	secs = secs%60;
-- 
2.13.1
