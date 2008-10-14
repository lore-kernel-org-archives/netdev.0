From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 09:52:46 +0000
Message-ID: <20081014095246.GA10804@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbYJNJwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:52:54 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:52:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The aim of this patch-set is to finish changes proposed by David S.
Miller in his patch-set with the same subject from Mon, 18 Aug 2008.
The first two patches were applied with some modifications, so, to
apply the rest, there were needed some changes.

Original David's patches include additional info, but signed-off-by
is removed because of changed context. I expect they will be merged
and signed off by David as an author, anyway.

The qdisc->requeue list idea is to limit requeuing to one level only,
so a parent can requeue to its child only. This list is then tried
first while dequeuing (qdisc_dequeue()), except at the top level,
so packets could be requeued only by qdiscs, not by qdisc_restart()
after xmit errors.

Thanks,
Jarek P.

 include/net/sch_generic.h |   23 +++++++++------
 net/sched/sch_api.c       |    7 -----
 net/sched/sch_atm.c       |   24 ++--------------
 net/sched/sch_cbq.c       |   37 +------------------------
 net/sched/sch_dsmark.c    |   23 +---------------
 net/sched/sch_fifo.c      |    2 -
 net/sched/sch_generic.c   |   21 +-------------
 net/sched/sch_gred.c      |   21 --------------
 net/sched/sch_hfsc.c      |   30 ++------------------
 net/sched/sch_htb.c       |   46 +------------------------------
 net/sched/sch_multiq.c    |   38 +------------------------
 net/sched/sch_netem.c     |   29 +++-----------------
 net/sched/sch_prio.c      |   31 +--------------------
 net/sched/sch_red.c       |   20 +-------------
 net/sched/sch_sfq.c       |   66 ---------------------------------------------
 net/sched/sch_tbf.c       |   23 +--------------
 net/sched/sch_teql.c      |   11 -------
 17 files changed, 36 insertions(+), 416 deletions(-)
