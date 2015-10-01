From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] act_mirred: always release tcf hash
Date: Thu,  1 Oct 2015 11:37:43 -0700
Message-ID: <1443724663-27158-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1443724663-27158-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36527 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756765AbbJASiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 14:38:15 -0400
Received: by pablk4 with SMTP id lk4so81324958pab.3
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 11:38:14 -0700 (PDT)
In-Reply-To: <1443724663-27158-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Align with other tc actions.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_mirred.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 3e7c51a..2efaf4e 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -107,10 +107,10 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	} else {
 		if (bind)
 			return 0;
-		if (!ovr) {
-			tcf_hash_release(a, bind);
+
+		tcf_hash_release(a, bind);
+		if (!ovr)
 			return -EEXIST;
-		}
 	}
 	m = to_mirred(a);
 
-- 
1.8.3.1
