From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] net/sched/sch_cbs: Fix compilation on 32bit architectures
Date: Thu, 26 Oct 2017 10:17:13 -0700
Message-ID: <20171026171714.45087-7-jeffrey.t.kirsher@intel.com>
References: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:17534 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932328AbdJZRRk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 13:17:40 -0400
In-Reply-To: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vinicius Costa Gomes <vinicius.gomes@intel.com>

There was still a couple of divisions of 64bit quantities happening,
which can fail to compile if there aren't instructions to handle that
kind of division.

It will fail with a message like this:

ERROR: "__aeabi_ldivmod" [net/sched/sch_cbs.ko] undefined!

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Tested-by: Henrik Austad <henrik@austad.us>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/sched/sch_cbs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_cbs.c b/net/sched/sch_cbs.c
index cae021c642e5..bdb533b7fb8c 100644
--- a/net/sched/sch_cbs.c
+++ b/net/sched/sch_cbs.c
@@ -331,8 +331,8 @@ static int cbs_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	opt.hicredit = q->hicredit;
 	opt.locredit = q->locredit;
-	opt.sendslope = q->sendslope / BYTES_PER_KBIT;
-	opt.idleslope = q->idleslope / BYTES_PER_KBIT;
+	opt.sendslope = div64_s64(q->sendslope, BYTES_PER_KBIT);
+	opt.idleslope = div64_s64(q->idleslope, BYTES_PER_KBIT);
 	opt.offload = q->offload;
 
 	if (nla_put(skb, TCA_CBS_PARMS, sizeof(opt), &opt))
-- 
2.14.2
