From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 8/9] tc: m_xt: Simplify argc adjusting in parse_ipt()
Date: Fri, 10 Jun 2016 13:42:07 +0200
Message-ID: <1465558928-19657-9-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60561 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086AbcFJLm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:42:28 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And while at it, also improve the error message in case too few
parameters have been given.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 55ebadf2cf50a..f449c9d1a6638 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -124,7 +124,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 
 	int c;
 	char **argv = *argv_p;
-	int argc = 0;
+	int argc;
 	char k[16];
 	int size = 0;
 	int iok = 0, ok = 0;
@@ -136,19 +136,14 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	xtables_init_all(&tmp_tcipt_globals, NFPROTO_IPV4);
 	set_lib_dir();
 
-	{
-		int i;
-
-		for (i = 0; i < *argc_p; i++) {
-			if (NULL == argv[i] || 0 == strcmp(argv[i], "action")) {
-				break;
-			}
-		}
-		argc = i;
+	/* parse only up until the next action */
+	for (argc = 0; argc < *argc_p; argc++) {
+		if (!argv[argc] || !strcmp(argv[argc], "action"))
+			break;
 	}
 
 	if (argc <= 2) {
-		fprintf(stderr, "bad arguments to ipt %d vs %d\n", argc, *argc_p);
+		fprintf(stderr, "too few arguments for xt, need at least '-j <target>'\n");
 		return -1;
 	}
 
-- 
2.8.2
