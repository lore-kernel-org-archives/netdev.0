From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: distinguish Add/Replace filter operations
Date: Wed, 16 Nov 2016 17:30:20 -0500
Message-ID: <1479335420-32088-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35790 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941444AbcKPWas (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:30:48 -0500
Received: by mail-it0-f65.google.com with SMTP id b123so10399547itb.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 14:30:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/tc_filter.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 932677a..ff8713b 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -226,6 +226,16 @@ int print_filter(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (n->nlmsg_type == RTM_DELTFILTER)
 		fprintf(fp, "deleted ");
 
+	if (n->nlmsg_type == RTM_NEWTFILTER &&
+			(n->nlmsg_flags & NLM_F_CREATE) &&
+			!(n->nlmsg_flags & NLM_F_EXCL))
+		fprintf(fp, "replaced ");
+
+	if (n->nlmsg_type == RTM_NEWTFILTER &&
+			(n->nlmsg_flags & NLM_F_CREATE) &&
+			(n->nlmsg_flags & NLM_F_EXCL))
+		fprintf(fp, "added ");
+
 	fprintf(fp, "filter ");
 	if (!filter_ifindex || filter_ifindex != t->tcm_ifindex)
 		fprintf(fp, "dev %s ", ll_index_to_name(t->tcm_ifindex));
-- 
1.9.1
