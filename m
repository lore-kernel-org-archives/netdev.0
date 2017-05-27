From: David Ahern <dsahern@gmail.com>
Subject: [PATCH iproute2 2/4] ip address: Move filter struct to ip_common.h
Date: Sat, 27 May 2017 17:34:48 -0600
Message-ID: <20170527233450.58015-3-dsahern@gmail.com>
References: <20170527233450.58015-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36670 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdE0Xe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 19:34:58 -0400
Received: by mail-pg0-f68.google.com with SMTP id h64so2561413pge.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 16:34:57 -0700 (PDT)
In-Reply-To: <20170527233450.58015-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move filter struct to ip_common.h as struct link_filter.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 ip/ip_common.h | 20 ++++++++++++++++++++
 ip/ipaddress.c | 22 +---------------------
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 450b45ac2b60..2b3cf7049b65 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -1,3 +1,23 @@
+struct link_filter {
+	int ifindex;
+	int family;
+	int oneline;
+	int showqueue;
+	inet_prefix pfx;
+	int scope, scopemask;
+	int flags, flagmask;
+	int up;
+	char *label;
+	int flushed;
+	char *flushb;
+	int flushp;
+	int flushe;
+	int group;
+	int master;
+	char *kind;
+	char *slave_kind;
+};
+
 int get_operstate(const char *name);
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index c805b929134d..3e2c38a8e53e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -44,27 +44,7 @@ enum {
 	IPADD_SAVE,
 };
 
-static struct
-{
-	int ifindex;
-	int family;
-	int oneline;
-	int showqueue;
-	inet_prefix pfx;
-	int scope, scopemask;
-	int flags, flagmask;
-	int up;
-	char *label;
-	int flushed;
-	char *flushb;
-	int flushp;
-	int flushe;
-	int group;
-	int master;
-	char *kind;
-	char *slave_kind;
-} filter;
-
+static struct link_filter filter;
 static int do_link;
 
 static void usage(void) __attribute__((noreturn));
-- 
2.11.0 (Apple Git-81)
