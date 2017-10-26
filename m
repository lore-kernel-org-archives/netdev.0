From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: distinguish Add/Replace qdisc operations
Date: Thu, 26 Oct 2017 17:30:08 -0400
Message-ID: <1509053408-18007-1-git-send-email-mrv@mojatatu.com>
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:47830 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdJZVaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 17:30:17 -0400
Received: by mail-io0-f196.google.com with SMTP id h70so8507930ioi.4
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 14:30:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 tc/tc_qdisc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 1e9d909..493538c 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -231,6 +231,16 @@ int print_qdisc(const struct sockaddr_nl *who,
 	if (n->nlmsg_type == RTM_DELQDISC)
 		fprintf(fp, "deleted ");
 
+	if (n->nlmsg_type == RTM_NEWQDISC &&
+			(n->nlmsg_flags & NLM_F_CREATE) &&
+			(n->nlmsg_flags & NLM_F_REPLACE))
+		fprintf(fp, "replaced ");
+
+	if (n->nlmsg_type == RTM_NEWQDISC &&
+			(n->nlmsg_flags & NLM_F_CREATE) &&
+			(n->nlmsg_flags & NLM_F_EXCL))
+		fprintf(fp, "added ");
+
 	if (show_raw)
 		fprintf(fp, "qdisc %s %x:[%08x]  ",
 			rta_getattr_str(tb[TCA_KIND]),
-- 
1.9.1
