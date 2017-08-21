From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 6/6] tc/q_multiq: Don't pass garbage in TCA_OPTIONS
Date: Mon, 21 Aug 2017 11:27:04 +0200
Message-ID: <20170821092704.21614-7-phil@nwl.cc>
References: <20170821092704.21614-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53647 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752804AbdHUJ1l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 05:27:41 -0400
In-Reply-To: <20170821092704.21614-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

multiq_parse_opt() doesn't change 'opt' at all. So at least make sure
it doesn't fill TCA_OPTIONS attribute with garbage from stack.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/q_multiq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/q_multiq.c b/tc/q_multiq.c
index 7823931494563..9c09c9a7748f6 100644
--- a/tc/q_multiq.c
+++ b/tc/q_multiq.c
@@ -43,7 +43,7 @@ static void explain(void)
 static int multiq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
-	struct tc_multiq_qopt opt;
+	struct tc_multiq_qopt opt = {};
 
 	if (argc) {
 		if (strcmp(*argv, "help") == 0) {
-- 
2.13.1
