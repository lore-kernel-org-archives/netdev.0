From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2] ss: fix display of raw sockets
Date: Wed, 15 Jul 2015 05:50:42 -0700
Message-ID: <1436964642-35194-1-git-send-email-nikolay@cumulusnetworks.com>
References: <55A64D99.9090702@beyondsemi.com>
Cc: eric.dumazet@gmail.com, miham@beyondsemi.com, vadim4j@gmail.com,
	davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33142 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbGOMus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 08:50:48 -0400
Received: by padck2 with SMTP id ck2so23748802pad.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 05:50:48 -0700 (PDT)
In-Reply-To: <55A64D99.9090702@beyondsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 8250bc9ff4e5 ("ss: Unify inet sockets output") raw sockets
are displayed as udp because dgram_show_line() is used for both and
thus IPPROTO_UDP is used for both so proto_name() returns "udp".
Fix this by checking dg_proto which is set according to the caller of
dgram_show_line().

Reported-by: Miha Marolt <miham@beyondsemi.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
note: use 0 instead of IPPROTO_RAW like Eric suggested

 misc/ss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 03f92fa69270..6abd1d1206b3 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1552,6 +1552,8 @@ out:
 static char *proto_name(int protocol)
 {
 	switch (protocol) {
+	case 0:
+		return "raw";
 	case IPPROTO_UDP:
 		return "udp";
 	case IPPROTO_TCP:
@@ -2416,7 +2418,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 	if (n < 9)
 		opt[0] = 0;
 
-	inet_stats_print(&s, IPPROTO_UDP);
+	inet_stats_print(&s, dg_proto == UDP_PROTO ? IPPROTO_UDP : 0);
 
 	if (show_details && opt[0])
 		printf(" opt:\"%s\"", opt);
-- 
1.9.3
