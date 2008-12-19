From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Annotate uninitialized var in sfq_enqueue()
Date: Fri, 19 Dec 2008 08:44:07 +0000
Message-ID: <20081219084407.GC7189@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:56746 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbYLSIoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 03:44:13 -0500
Received: by ug-out-1314.google.com with SMTP id 39so538527ugf.37
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 00:44:11 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some gcc versions warn that ret may be used uninitialized in
sfq_enqueue(). It's a false positive, so let's annotate this.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_sfq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index ab8cfee..f3965df 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -281,7 +281,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned int hash;
 	sfq_index x;
-	int ret;
+	int uninitialized_var(ret);
 
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
