From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH iproute2] ss: print value of IPV6_V6ONLY socket option if set
Date: Wed, 24 Jun 2015 13:07:20 +0200
Message-ID: <1435144040-26325-1-git-send-email-phil@nwl.cc>
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45673 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527AbbFXLHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 07:07:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If available and set, print 'v6only:1' for AF_INET6 sockets upon request
of extended information. For IPv6 sockets bound to in6addr_any, this is
the only way to determine if they will also accept IPv4 requests or not.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Depends on unapplied patch 'ss: Include -E option for socket destroy
events'

Kernel support patch: 204621551b2a0060a013b92f7add4d5c452fa7cb
---
 include/linux/inet_diag.h | 3 ++-
 misc/ss.c                 | 5 +++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index e83340b..1db4116 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -112,9 +112,10 @@ enum {
 	INET_DIAG_SHUTDOWN,
 	INET_DIAG_DCTCPINFO,
 	INET_DIAG_PROTOCOL,  /* response attribute only */
+	INET_DIAG_SKV6ONLY,
 };
 
-#define INET_DIAG_MAX INET_DIAG_PROTOCOL
+#define INET_DIAG_MAX INET_DIAG_SKV6ONLY
 
 /* INET_DIAG_MEM */
 
diff --git a/misc/ss.c b/misc/ss.c
index 759795c..62a638b 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2047,6 +2047,11 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 
 	if (show_details) {
 		sock_details_print(&s);
+		if (s.local.family == AF_INET6 && tb[INET_DIAG_SKV6ONLY]) {
+			unsigned char v6only;
+			v6only = *(__u8 *)RTA_DATA(tb[INET_DIAG_SKV6ONLY]);
+			printf(" v6only:%u", v6only);
+		}
 		if (tb[INET_DIAG_SHUTDOWN]) {
 			unsigned char mask;
 			mask = *(__u8 *)RTA_DATA(tb[INET_DIAG_SHUTDOWN]);
-- 
2.1.2
