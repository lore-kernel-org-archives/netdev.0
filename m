From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH v3] lib: Replace 16384 netlink buf size by macro
Date: Fri, 27 Feb 2015 08:18:54 +0200
Message-ID: <1425017934-32061-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:33164 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbbB0GaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 01:30:17 -0500
Received: by labgf13 with SMTP id gf13so15582025lab.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 22:30:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Replaced hard coded 16384 netlink buffer size by NLBUF_SIZE,
which can be overridden by -DNLBUF_SIZE.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
v3:
    Fixed "overrided" -> overridden" in the
    commit message   : suggested by Sergei Shtylyov

v2:
    Get rid of NL_BUF: suggested by Jiri Pirko

 include/libnetlink.h | 4 ++++
 ip/iplink.c          | 2 +-
 lib/libnetlink.c     | 8 ++++----
 misc/ss.c            | 2 +-
 4 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 898275b..1ef7f1f 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -170,5 +170,9 @@ extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
  * messages from dump file */
 #define NLMSG_TSTAMP	15
 
+#ifndef NLBUF_SIZE
+#define NLBUF_SIZE 16384
+#endif
+
 #endif /* __LIBNETLINK_H__ */
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 5893ee4..db60afa 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -770,7 +770,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 {
 	int len;
 	struct iplink_req req;
-	char answer[16384];
+	char answer[NLBUF_SIZE];
 
 	memset(&req, 0, sizeof(req));
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 77e07ef..666e277 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -194,7 +194,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char buf[16384];
+	char buf[NLBUF_SIZE];
 	int dump_intr = 0;
 
 	iov.iov_base = buf;
@@ -317,7 +317,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[16384];
+	char buf[NLBUF_SIZE];
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
@@ -432,7 +432,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[16384];
+	char buf[NLBUF_SIZE];
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
@@ -498,7 +498,7 @@ int rtnl_from_file(FILE *rtnl, rtnl_filter_t handler,
 {
 	int status;
 	struct sockaddr_nl nladdr;
-	char   buf[16384];
+	char buf[NLBUF_SIZE];
 	struct nlmsghdr *h = (void*)buf;
 
 	memset(&nladdr, 0, sizeof(nladdr));
diff --git a/misc/ss.c b/misc/ss.c
index 21a4366..036ede8 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2222,7 +2222,7 @@ Exit:
 static int tcp_show_netlink_file(struct filter *f)
 {
 	FILE	*fp;
-	char	buf[16384];
+	char buf[NLBUF_SIZE];
 
 	if ((fp = fopen(getenv("TCPDIAG_FILE"), "r")) == NULL) {
 		perror("fopen($TCPDIAG_FILE)");
-- 
2.2.2
