From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 2/2] skbedit print missing metadata
Date: Sat, 21 Dec 2013 16:38:37 -0500
Message-ID: <1387661917-29520-3-git-send-email-jhs@mojatatu.com>
References: <1387661917-29520-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:46377 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098Ab3LUVjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 16:39:12 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so4633014ieb.39
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 13:39:12 -0800 (PST)
In-Reply-To: <1387661917-29520-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skbedit should print the index and other generic metadata info

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_skbedit.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 6b582f3..4b4ee06 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -165,6 +165,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	__u32 *priority;
 	__u32 *mark;
 	__u16 *queue_mapping;
+	struct tc_skbedit *p = NULL;
 
 	if (arg == NULL)
 		return -1;
@@ -175,6 +176,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, "[NULL skbedit parameters]");
 		return -1;
 	}
+	p = RTA_DATA(tb[TCA_SKBEDIT_PARMS]);
 
 	fprintf(f, " skbedit");
 
@@ -191,6 +193,8 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, " mark %d", *mark);
 	}
 
+	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
+
 	if (show_stats) {
 		if (tb[TCA_SKBEDIT_TM]) {
 			struct tcf_t *tm = RTA_DATA(tb[TCA_SKBEDIT_TM]);
@@ -198,6 +202,8 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		}
 	}
 
+	fprintf(f, "\n ");
+
 	return 0;
 }
 
-- 
1.7.9.5
