From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] tc: fix a misleading failure
Date: Mon,  8 Aug 2016 16:24:45 -0700
Message-ID: <1470698685-20177-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <shemming@brocade.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35282 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156AbcHHXYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 19:24:54 -0400
Received: by mail-pa0-f65.google.com with SMTP id cf3so24649019pad.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 16:24:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch:

 # ./tc/tc actions add action drop index 11
 RTNETLINK answers: File exists
 We have an error talking to the kernel
 Command "(null)" is unknown, try "tc actions help".

After this patch:

 # ./tc/tc actions add action drop index 11
 RTNETLINK answers: File exists
 We have an error talking to the kernel

Cc: Stephen Hemminger <shemming@brocade.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 tc/m_action.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index 24f8b5d..bb19df8 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -623,14 +623,12 @@ int do_action(int argc, char **argv)
 			act_usage();
 			return -1;
 		} else {
-
-			ret = -1;
-		}
-
-		if (ret < 0) {
 			fprintf(stderr, "Command \"%s\" is unknown, try \"tc actions help\".\n", *argv);
 			return -1;
 		}
+
+		if (ret < 0)
+			return -1;
 	}
 
 	return 0;
-- 
2.1.0
