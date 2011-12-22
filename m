From: Thomas Graf <tgraf@redhat.com>
Subject: [PATCH] mqprio: Avoid panic if no options are provided
Date: Thu, 22 Dec 2011 13:05:07 +0100
Message-ID: <1324555507-10148-1-git-send-email-tgraf@redhat.com>
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	Thomas Graf <tgraf@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398Ab1LVMFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 07:05:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace may not provide TCA_OPTIONS, in fact tc currently does
so not do so if no arguments are specified on the command line.
Return EINVAL instead of panicing.

Signed-off-by: Thomas Graf <tgraf@redhat.com>
---
 net/sched/sch_mqprio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index f88256c..28de430 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -107,7 +107,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!netif_is_multiqueue(dev))
 		return -EOPNOTSUPP;
 
-	if (nla_len(opt) < sizeof(*qopt))
+	if (!opt || nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
 
 	qopt = nla_data(opt);
-- 
1.7.7.4
