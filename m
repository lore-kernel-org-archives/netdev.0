From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: print raw qdisc handle.
Date: Sun,  6 Nov 2016 21:16:59 -0500
Message-ID: <1478485019-9438-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@emojatatu.com,
        stephen@networkplumber.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34175 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751169AbcKGCRU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 21:17:20 -0500
Received: by mail-it0-f65.google.com with SMTP id q124so6856039itd.1
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 18:17:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/tc_qdisc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index a63c476..9b06b8f 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -238,7 +238,14 @@ int print_qdisc(const struct sockaddr_nl *who,
 	if (n->nlmsg_type == RTM_DELQDISC)
 		fprintf(fp, "deleted ");
 
-	fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]), t->tcm_handle>>16);
+	if (!show_raw) {
+	   fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]),
+			t->tcm_handle >> 16);
+	} else {
+	   fprintf(fp, "qdisc %s %x:[%08x] ", rta_getattr_str(tb[TCA_KIND]),
+			t->tcm_handle >> 16, t->tcm_handle);
+	}
+
 	if (filter_ifindex == 0)
 		fprintf(fp, "dev %s ", ll_index_to_name(t->tcm_ifindex));
 	if (t->tcm_parent == TC_H_ROOT)
-- 
1.9.1
