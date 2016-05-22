From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] tc fix ife late binding
Date: Sun, 22 May 2016 13:11:16 -0400
Message-ID: <1463937076-31395-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35419 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbcEVRLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 13:11:39 -0400
Received: by mail-it0-f66.google.com with SMTP id z123so2800215itg.2
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 10:11:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

following late binding didn't work

sudo tc actions add action ife encode \
type 0xDEAD allow mark dst 02:15:15:15:15:15 index 1

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_ife.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index ed01ff7..c8ae04d 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -182,6 +182,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 				fprintf(stderr, "ife: Illegal \"index\"\n");
 				return -1;
 			}
+			ok++;
 			argc--;
 			argv++;
 		}
-- 
1.9.1
