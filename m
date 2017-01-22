From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: distinguish Add/Replace action operations.
Date: Sun, 22 Jan 2017 08:55:33 -0500
Message-ID: <1485093333-18317-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35186 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbdAVN4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 08:56:41 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so7572339ith.2
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 05:56:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_action.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index bb19df8..05ef07e 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -365,12 +365,18 @@ int print_action(const struct sockaddr_nl *who,
 			fprintf(fp, "Flushed table ");
 			tab_flush = 1;
 		} else {
-			fprintf(fp, "deleted action ");
+			fprintf(fp, "Deleted action ");
 		}
 	}
 
-	if (n->nlmsg_type == RTM_NEWACTION)
-		fprintf(fp, "Added action ");
+	if (n->nlmsg_type == RTM_NEWACTION) {
+		if ((n->nlmsg_flags & NLM_F_CREATE) &&
+		    !(n->nlmsg_flags & NLM_F_REPLACE)) {
+			fprintf(fp, "Added action ");
+		} else if (n->nlmsg_flags & NLM_F_REPLACE) {
+			fprintf(fp, "Replaced action ");
+		}
+	}
 	tc_print_action(fp, tb[TCA_ACT_TAB]);
 
 	return 0;
-- 
1.9.1
