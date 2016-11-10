From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: print raw qdisc handle.
Date: Thu, 10 Nov 2016 10:06:32 -0500
Message-ID: <1478790392-13028-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35705 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933387AbcKJPHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 10:07:00 -0500
Received: by mail-it0-f65.google.com with SMTP id b123so3989072itb.2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 07:07:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending patch after fixing indentation and spaces.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/tc_qdisc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 93c9a4c..a8c8386 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -231,7 +231,15 @@ int print_qdisc(const struct sockaddr_nl *who,
 	if (n->nlmsg_type == RTM_DELQDISC)
 		fprintf(fp, "deleted ");
 
-	fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]), t->tcm_handle>>16);
+	if (!show_raw) {
+		fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]),
+				t->tcm_handle >> 16);
+	} else {
+		fprintf(fp, "qdisc %s %x:[%08x]  ",
+				rta_getattr_str(tb[TCA_KIND]),
+				t->tcm_handle >> 16, t->tcm_handle);
+	}
+
 	if (filter_ifindex == 0)
 		fprintf(fp, "dev %s ", ll_index_to_name(t->tcm_ifindex));
 	if (t->tcm_parent == TC_H_ROOT)
-- 
1.9.1
