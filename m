From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] net_sched: cls_cgroup: remove unnecessary if
Date: Tue,  2 Dec 2014 18:00:36 +0100
Message-ID: <1417539636-12710-7-git-send-email-jiri@resnulli.us>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:46638 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbaLBRGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:06:54 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so17424046wgh.23
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:06:53 -0800 (PST)
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since head->handle == handle (checked before), just assign handle.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_cgroup.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index d61a801..dbee65e 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -117,11 +117,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 		return -ENOBUFS;
 
 	tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
-	if (head)
-		new->handle = head->handle;
-	else
-		new->handle = handle;
-
+	new->handle = handle;
 	new->tp = tp;
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
 			       cgroup_policy);
-- 
1.9.3
