From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] multiq: remove root-only requirement from multiq_tune
Date: Fri, 12 Sep 2008 15:36:00 -0700
Message-ID: <20080912223600.6498.54511.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:56873 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496AbYILWgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 18:36:02 -0400
Received: by rv-out-0506.google.com with SMTP id k40so999430rvb.1
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 15:36:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes the root-only requirement for the multiq qdisc so that
you can have prio as a parent if you wish.  This may lead to some odd
behaviors when parent qdiscs are not multiqueue aware.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/sched/sch_multiq.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index ce00df4..49a8b67 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -202,8 +202,6 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 	struct tc_multiq_qopt *qopt;
 	int i;
 
-	if (sch->parent != TC_H_ROOT)
-		return -EINVAL;
 	if (!netif_is_multiqueue(qdisc_dev(sch)))
 		return -EINVAL;
 	if (nla_len(opt) < sizeof(*qopt))

