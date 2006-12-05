From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 3/7] [IP] RULE: Add ifdef to FIB_RULE_INVERT since it is missing.
Date: Tue,  5 Dec 2006 19:15:33 +0900
Message-ID: <11653137331688-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:38924 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S967798AbWLEKQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:16:02 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/iprule.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index c584b18..1da64b8 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -83,8 +83,10 @@ int print_rule(const struct sockaddr_nl 
 	else
 		fprintf(fp, "0:\t");
 
+#ifdef FIB_RULE_INVERT
 	if (r->rtm_flags & FIB_RULE_INVERT)
 		fprintf(fp, "not ");
+#endif
 
 	if (tb[RTA_SRC]) {
 		if (r->rtm_src_len != host_len) {
@@ -224,7 +226,9 @@ static int iprule_modify(int cmd, int ar
 
 	while (argc > 0) {
 		if (strcmp(*argv, "not") == 0) {
+#ifdef FIB_RULE_INVERT
 			req.r.rtm_flags |= FIB_RULE_INVERT;
+#endif
 		} else if (strcmp(*argv, "from") == 0) {
 			inet_prefix dst;
 			NEXT_ARG();
-- 
1.4.2

