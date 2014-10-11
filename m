From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] netlink: extend buffers to 16K
Date: Sat, 11 Oct 2014 09:43:13 -0700
Message-ID: <1413045793.9362.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:54259 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbaJKQnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 12:43:15 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so3377189pdj.12
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2014 09:43:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Starting from linux-3.15 (commit 9063e21fb026, "netlink: autosize skb
lengths"), kernel is able to send up to 16K in netlink replies.

This change enables iproute2 commands to get bigger chunks,
without breaking compatibility with old kernels.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 lib/libnetlink.c |    4 ++--
 misc/ss.c        |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 9e2a795..8d504a9 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -420,7 +420,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[8192];
+	char   buf[16384];
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
@@ -486,7 +486,7 @@ int rtnl_from_file(FILE *rtnl, rtnl_filter_t handler,
 {
 	int status;
 	struct sockaddr_nl nladdr;
-	char   buf[8192];
+	char   buf[16384];
 	struct nlmsghdr *h = (void*)buf;
 
 	memset(&nladdr, 0, sizeof(nladdr));
diff --git a/misc/ss.c b/misc/ss.c
index 2420b51..d185040 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1864,7 +1864,7 @@ static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 	int fd, family;
 	struct sockaddr_nl nladdr;
 	struct msghdr msg;
-	char	buf[8192];
+	char	buf[16384];
 	struct iovec iov[3];
 
 	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
@@ -1980,7 +1980,7 @@ done:
 static int tcp_show_netlink_file(struct filter *f)
 {
 	FILE	*fp;
-	char	buf[8192];
+	char	buf[16384];
 
 	if ((fp = fopen(getenv("TCPDIAG_FILE"), "r")) == NULL) {
 		perror("fopen($TCPDIAG_FILE)");
@@ -2497,7 +2497,7 @@ static int handle_netlink_request(struct filter *f, FILE *dump_fp,
 				  int (* show_one_sock)(struct nlmsghdr *nlh, struct filter *f))
 {
 	int fd;
-	char	buf[8192];
+	char	buf[16384];
 
 	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
 		return -1;
@@ -2782,7 +2782,7 @@ static int packet_show_netlink(struct filter *f, FILE *dump_fp)
 		struct nlmsghdr nlh;
 		struct packet_diag_req r;
 	} req;
-	char	buf[8192];
+	char	buf[16384];
 
 	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
 		return -1;
