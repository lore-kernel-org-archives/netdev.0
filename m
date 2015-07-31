From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] act_pedit: check binding before calling tcf_hash_release()
Date: Thu, 30 Jul 2015 17:12:21 -0700
Message-ID: <1438301541-26192-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32885 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbGaAMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 20:12:32 -0400
Received: by pacom8 with SMTP id om8so2860255pac.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 17:12:31 -0700 (PDT)
In-Reply-To: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we share an action within a filter, the bind refcnt
should increase, therefore we should not call tcf_hash_release().

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/act_pedit.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 17e6d66..ff8b466 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -68,13 +68,12 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		}
 		ret = ACT_P_CREATED;
 	} else {
-		p = to_pedit(a);
-		tcf_hash_release(a, bind);
 		if (bind)
 			return 0;
+		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
-
+		p = to_pedit(a);
 		if (p->tcfp_nkeys && p->tcfp_nkeys != parm->nkeys) {
 			keys = kmalloc(ksize, GFP_KERNEL);
 			if (keys == NULL)
-- 
1.8.3.1
