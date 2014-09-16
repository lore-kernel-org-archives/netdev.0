From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: sched: cls_cgroup need tcf_exts_init in all
 cases
Date: Tue, 16 Sep 2014 00:33:42 -0700
Message-ID: <20140916073341.2597.36240.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:41164 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbaIPHd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 03:33:57 -0400
Received: by mail-ob0-f175.google.com with SMTP id vb8so2402723obc.34
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 00:33:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures the tcf_exts_init() is called for all cases.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_cgroup.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 10c7ffd..15c34d4 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -116,12 +116,11 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (!new)
 		return -ENOBUFS;
 
-	if (head) {
+	tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+	if (head)
 		new->handle = head->handle;
-	} else {
-		tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+	else
 		new->handle = handle;
-	}
 
 	new->tp = tp;
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
