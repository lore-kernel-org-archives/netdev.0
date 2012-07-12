From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] sch_sfb: Fix missing NULL check
Date: Thu, 12 Jul 2012 14:39:11 +0100
Message-ID: <20120712133847.18719.77998.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:59687 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759239Ab2GLNWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 09:22:24 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q6CDtjev021410
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 14:55:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Resolves-bug: https://bugzilla.kernel.org/show_bug.cgi?id=44461
Signed-off-by: Alan Cox <alna@linux.intel.com>
---

 net/sched/sch_sfb.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 74305c8..30ea467 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -570,6 +570,8 @@ static int sfb_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	sch->qstats.backlog = q->qdisc->qstats.backlog;
 	opts = nla_nest_start(skb, TCA_OPTIONS);
+	if (opts == NULL)
+		goto nla_put_failure;
 	if (nla_put(skb, TCA_SFB_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 	return nla_nest_end(skb, opts);
