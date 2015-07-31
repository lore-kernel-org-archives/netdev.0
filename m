From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] act_mirred: avoid calling tcf_hash_release() when binding
Date: Thu, 30 Jul 2015 17:12:20 -0700
Message-ID: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f194.google.com ([209.85.192.194]:34063 "EHLO
	mail-pd0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbGaA1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 20:27:48 -0400
Received: by pdav4 with SMTP id v4so3083299pda.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 17:27:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we share an action within a filter, the bind refcnt
should increase, therefore we should not call tcf_hash_release().

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/act_mirred.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index a42a3b2..2685450 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -98,6 +98,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
+		if (bind)
+			return 0;
 		if (!ovr) {
 			tcf_hash_release(a, bind);
 			return -EEXIST;
-- 
1.8.3.1
