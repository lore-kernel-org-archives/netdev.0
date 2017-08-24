From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 2/4] tc/q_netem: Don't dereference possibly NULL pointer
Date: Thu, 24 Aug 2017 11:46:32 +0200
Message-ID: <20170824094634.4093-3-phil@nwl.cc>
References: <20170824094634.4093-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33407 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752358AbdHXJqr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:46:47 -0400
In-Reply-To: <20170824094634.4093-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assuming 'opt' might be NULL, move the call to RTA_PAYLOAD to after the
check since it dereferences its parameter.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v2:
- Dropped empty line between assignment and check.
---
 tc/q_netem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index 0975ae111de97..5a9e747411e85 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -538,7 +538,7 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	int *ecn = NULL;
 	struct tc_netem_qopt qopt;
 	const struct tc_netem_rate *rate = NULL;
-	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
+	int len;
 	__u64 rate64 = 0;
 
 	SPRINT_BUF(b1);
@@ -546,6 +546,7 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (opt == NULL)
 		return 0;
 
+	len = RTA_PAYLOAD(opt) - sizeof(qopt);
 	if (len < 0) {
 		fprintf(stderr, "options size error\n");
 		return -1;
-- 
2.13.1
