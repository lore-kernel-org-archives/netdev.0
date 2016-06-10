From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 7/9] tc: m_xt: Get rid of iargc variable in parse_ipt()
Date: Fri, 10 Jun 2016 13:42:06 +0200
Message-ID: <1465558928-19657-8-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58875 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293AbcFJLm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:42:59 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After dropping the unused decrement of argc in the function's tail, it
can fully take over what iargc has been used for.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 61fc437dfc907..55ebadf2cf50a 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -124,7 +124,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 
 	int c;
 	char **argv = *argv_p;
-	int argc = 0, iargc = 0;
+	int argc = 0;
 	char k[16];
 	int size = 0;
 	int iok = 0, ok = 0;
@@ -144,7 +144,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 				break;
 			}
 		}
-		iargc = argc = i;
+		argc = i;
 	}
 
 	if (argc <= 2) {
@@ -205,7 +205,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 		}
 	}
 
-	if (iargc > optind) {
+	if (argc > optind) {
 		if (matches(argv[optind], "index") == 0) {
 			if (get_u32(&index, argv[optind + 1], 10)) {
 				fprintf(stderr, "Illegal \"index\"\n");
@@ -271,9 +271,8 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 		addattr_l(n, MAX_MSG, TCA_IPT_TARG, m->t, m->t->u.target_size);
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 
-	argc -= optind;
 	argv += optind;
-	*argc_p -= iargc;
+	*argc_p -= argc;
 	*argv_p = argv;
 
 	optind = 0;
-- 
2.8.2
