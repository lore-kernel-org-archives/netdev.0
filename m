From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 53/61] net/sched/sch_tbf.c:399:3: note: in
 expansion of macro 'if'
Date: Mon, 13 Mar 2017 00:00:30 -0700 (PDT)
Message-ID: <20170313.000030.1021237791287933829.davem@davemloft.net>
References: <201703131411.0uOifOO0%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jkosina@suse.cz, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54802 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdCMHAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:00:32 -0400
In-Reply-To: <201703131411.0uOifOO0%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Mon, 13 Mar 2017 14:49:27 +0800

>>> net/sched/sch_tbf.c:399:3: note: in expansion of macro 'if'
>       if (child != &noop_qdisc);
>       ^~
>    net/sched/sch_tbf.c:400:4: note: ...this statement, but the latter is misleadingly indented as if it is guarded by the 'if'
>        qdisc_hash_add(child, true);
>        ^~~~~~~~~~~~~~

Now fixes as follows:

====================
[PATCH] sch_tbf: Remove bogus semicolon in if() conditional.

Fixes: 49b499718fa1 ("net: sched: make default fifo qdiscs appear in the dump")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_tbf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 40c29a8..9850126 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -396,7 +396,7 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 					  q->qdisc->qstats.backlog);
 		qdisc_destroy(q->qdisc);
 		q->qdisc = child;
-		if (child != &noop_qdisc);
+		if (child != &noop_qdisc)
 			qdisc_hash_add(child, true);
 	}
 	q->limit = qopt->limit;
-- 
2.1.0
