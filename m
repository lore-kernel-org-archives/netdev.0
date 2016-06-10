From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 6/9] tc: m_xt: Get rid of rargc in parse_ipt()
Date: Fri, 10 Jun 2016 13:42:05 +0200
Message-ID: <1465558928-19657-7-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40415 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbcFJLmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:42:22 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to copy the passed parameter, it's changed only once right
before function return.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index c42f3bda4e8f4..61fc437dfc907 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -123,7 +123,6 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	struct rtattr *tail;
 
 	int c;
-	int rargc = *argc_p;
 	char **argv = *argv_p;
 	int argc = 0, iargc = 0;
 	char k[16];
@@ -140,7 +139,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	{
 		int i;
 
-		for (i = 0; i < rargc; i++) {
+		for (i = 0; i < *argc_p; i++) {
 			if (NULL == argv[i] || 0 == strcmp(argv[i], "action")) {
 				break;
 			}
@@ -149,7 +148,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	}
 
 	if (argc <= 2) {
-		fprintf(stderr, "bad arguments to ipt %d vs %d\n", argc, rargc);
+		fprintf(stderr, "bad arguments to ipt %d vs %d\n", argc, *argc_p);
 		return -1;
 	}
 
@@ -274,7 +273,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 
 	argc -= optind;
 	argv += optind;
-	*argc_p = rargc - iargc;
+	*argc_p -= iargc;
 	*argv_p = argv;
 
 	optind = 0;
-- 
2.8.2
