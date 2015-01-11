From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] actions: Get vlan action to work in pipeline
Date: Sun, 11 Jan 2015 09:31:30 -0500
Message-ID: <1420986690-1563-1-git-send-email-jhs@emojatatu.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:44710 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbbAKOdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 09:33:42 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so21816705ier.4
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 06:33:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

When specified in a graph such as:
action vlan ... action foobar
the vlan action chewed more than it can swallow

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_vlan.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 171d268..32db5ed 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -103,20 +103,25 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 	if (argc) {
 		if (matches(*argv, "reclassify") == 0) {
 			parm.action = TC_ACT_RECLASSIFY;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "pipe") == 0) {
 			parm.action = TC_ACT_PIPE;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "drop") == 0 ||
 			   matches(*argv, "shot") == 0) {
 			parm.action = TC_ACT_SHOT;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "continue") == 0) {
 			parm.action = TC_ACT_UNSPEC;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "pass") == 0) {
 			parm.action = TC_ACT_OK;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		}
 	}
 
@@ -198,6 +203,7 @@ static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
 		}
 		break;
 	}
+	fprintf(f, " %s", action_n2a(parm->action, b1, sizeof (b1)));
 
 	fprintf(f, "\n\t index %d ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
-- 
1.7.9.5
