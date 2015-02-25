From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] lib: Replace 16384 netlink buf by macro
Date: Wed, 25 Feb 2015 18:04:17 +0200
Message-ID: <1424880257-20657-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:40839 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbBYQPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:15:37 -0500
Received: by lbdu10 with SMTP id u10so4902110lbd.7
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 08:15:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Replaced hard coded 16384 sized netlink message buffer
by NL_BUF(x) macro.

Buffer size can be overrided by -DNLBUF_SIZE.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/libnetlink.h | 6 ++++++
 ip/iplink.c          | 2 +-
 lib/libnetlink.c     | 8 ++++----
 misc/ss.c            | 2 +-
 4 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 898275b..883f581 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -170,5 +170,11 @@ extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
  * messages from dump file */
 #define NLMSG_TSTAMP	15
 
+#ifndef NLBUF_SIZE
+#define NLBUF_SIZE 16384
+#endif
+
+#define NL_BUF(b) char  b[NLBUF_SIZE]
+
 #endif /* __LIBNETLINK_H__ */
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 5893ee4..b9949a8 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -770,7 +770,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 {
 	int len;
 	struct iplink_req req;
-	char answer[16384];
+	NL_BUF(answer);
 
 	memset(&req, 0, sizeof(req));
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 77e07ef..1f7a173 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -194,7 +194,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char buf[16384];
+	NL_BUF(buf);
 	int dump_intr = 0;
 
 	iov.iov_base = buf;
@@ -317,7 +317,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[16384];
+	NL_BUF(buf);
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
@@ -432,7 +432,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[16384];
+	NL_BUF(buf);
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
@@ -498,7 +498,7 @@ int rtnl_from_file(FILE *rtnl, rtnl_filter_t handler,
 {
 	int status;
 	struct sockaddr_nl nladdr;
-	char   buf[16384];
+	NL_BUF(buf);
 	struct nlmsghdr *h = (void*)buf;
 
 	memset(&nladdr, 0, sizeof(nladdr));
diff --git a/misc/ss.c b/misc/ss.c
index 21a4366..0bd110f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2222,7 +2222,7 @@ Exit:
 static int tcp_show_netlink_file(struct filter *f)
 {
 	FILE	*fp;
-	char	buf[16384];
+	NL_BUF(buf);
 
 	if ((fp = fopen(getenv("TCPDIAG_FILE"), "r")) == NULL) {
 		perror("fopen($TCPDIAG_FILE)");
-- 
2.2.2
