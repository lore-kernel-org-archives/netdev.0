From: Petr Sabata <contyk@redhat.com>
Subject: [PATCH] iproute2: Remove unreachable code
Date: Fri, 10 Jun 2011 15:19:07 +0200
Message-ID: <1307711947-586-1-git-send-email-contyk@redhat.com>
Cc: Petr Sabata <contyk@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381Ab1FJNS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 09:18:59 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5ADIx29015934
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 09:18:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes unreachable, useless code.

Signed-off-by: Petr Sabata <contyk@redhat.com>
---
 genl/genl.c   |    6 ------
 tc/f_cgroup.c |    1 -
 tc/q_drr.c    |    3 +--
 tc/q_multiq.c |    3 +--
 4 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/genl/genl.c b/genl/genl.c
index 3ae75ae..7ec24eb 100644
--- a/genl/genl.c
+++ b/genl/genl.c
@@ -150,12 +150,6 @@ int main(int argc, char **argv)
 
 		ret = a->parse_genlopt(a, argc-1, argv+1);
 		return ret;
-
-		if (matches(argv[1], "help") == 0)
-			usage();
-		fprintf(stderr, "Object \"%s\" is unknown, try \"genl "
-			"-help\".\n", argv[1]);
-		exit(-1);
 	}
 
 	usage();
diff --git a/tc/f_cgroup.c b/tc/f_cgroup.c
index 192e697..4a4026e 100644
--- a/tc/f_cgroup.c
+++ b/tc/f_cgroup.c
@@ -74,7 +74,6 @@ static int cgroup_parse_opt(struct filter_util *qu, char *handle,
 			explain();
 			return -1;
 		}
-		argc--; argv++;
 	}
 
 	tail->rta_len = (((void*)n)+n->nlmsg_len) - (void*)tail;
diff --git a/tc/q_drr.c b/tc/q_drr.c
index 81de44d..9d3788f 100644
--- a/tc/q_drr.c
+++ b/tc/q_drr.c
@@ -36,7 +36,7 @@ static void explain2(void)
 
 static int drr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	while (argc > 0) {
+	while (argc) {
 		if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -45,7 +45,6 @@ static int drr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 			explain();
 			return -1;
 		}
-		argc--; argv++;
 	}
 	return 0;
 }
diff --git a/tc/q_multiq.c b/tc/q_multiq.c
index fce5e44..7ff9e74 100644
--- a/tc/q_multiq.c
+++ b/tc/q_multiq.c
@@ -46,7 +46,7 @@ static int multiq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 {
 	struct tc_multiq_qopt opt;
 
-	if (argc > 0) {
+	if (argc) {
 		if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -55,7 +55,6 @@ static int multiq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			explain();
 			return -1;
 		}
-		argc--; argv++;
 	}
 
 	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
-- 
1.7.5.2

