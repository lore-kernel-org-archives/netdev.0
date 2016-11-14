From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH v2 iproute2 1/1] tc: print raw qdisc handle.
Date: Mon, 14 Nov 2016 17:59:20 -0500
Message-ID: <1479164360-24188-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34503 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938725AbcKNW7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 17:59:40 -0500
Received: by mail-it0-f66.google.com with SMTP id q124so17559026itd.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:59:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v2 patch with fixed code indentation.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/tc_qdisc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 93c9a4c..6f60002 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -231,7 +231,15 @@ int print_qdisc(const struct sockaddr_nl *who,
 	if (n->nlmsg_type == RTM_DELQDISC)
 		fprintf(fp, "deleted ");
 
-	fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]), t->tcm_handle>>16);
+	if (!show_raw) {
+		fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]),
+			t->tcm_handle >> 16);
+	} else {
+		fprintf(fp, "qdisc %s %x:[%08x]  ",
+			rta_getattr_str(tb[TCA_KIND]),
+			t->tcm_handle >> 16, t->tcm_handle);
+	}
+
 	if (filter_ifindex == 0)
 		fprintf(fp, "dev %s ", ll_index_to_name(t->tcm_ifindex));
 	if (t->tcm_parent == TC_H_ROOT)
-- 
1.9.1
