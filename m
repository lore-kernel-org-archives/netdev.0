From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 42/51] tc/q_netem: Don't dereference possibly NULL pointer
Date: Sat, 12 Aug 2017 14:05:01 +0200
Message-ID: <20170812120510.28750-43-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54861 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752207AbdHLMJV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:21 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assuming 'opt' might be NULL, move the call to RTA_PAYLOAD to after the
check since it dereferences its parameter.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/q_netem.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index 0975ae111de97..7e3330512041a 100644
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
@@ -546,6 +546,8 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (opt == NULL)
 		return 0;
 
+	len = RTA_PAYLOAD(opt) - sizeof(qopt);
+
 	if (len < 0) {
 		fprintf(stderr, "options size error\n");
 		return -1;
-- 
2.13.1
