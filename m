From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 12/14] sch_htb: Fix a compiler warning in htb_enqueue().
Date: Tue, 14 Oct 2008 09:55:23 +0000
Message-ID: <20081014095522.GM10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059AbYJNJz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:55:27 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:55:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use uninitialized_var(ret) in htb_enqueue() to avoid a compiler warning.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index b2f9e96..c0c83c8 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -551,7 +551,7 @@ static inline void htb_deactivate(struct htb_sched *q, struct htb_class *cl)
 
 static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	int ret;
+	int uninitialized_var(ret);
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = htb_classify(skb, sch, &ret);
 
-- 
1.5.6.5

