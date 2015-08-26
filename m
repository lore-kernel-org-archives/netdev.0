From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 0/5] net_sched: introduce static flags for qdisc's
Date: Wed, 26 Aug 2015 15:41:22 -0700
Message-ID: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36441 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbbHZWld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:41:33 -0400
Received: by pacgr6 with SMTP id gr6so1899886pac.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 15:41:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main goal of this patchset is to improve the behavior of setting
the default qdisc. Current behavior has no error check, no check for
ingress and _can_ crash the kernel with some buggy implementation.

We only have flags for each instance of qdisc's, for flags like
if a qdisc is a fifo qdisc, they can simply be moved into qdisc->ops,
as shown by patch 1, 2, 5. Patch 4 just uses this for error checking
when setting default qdisc.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---

Cong Wang (5):
  net_sched: move some qdisc flag into qdisc ops
  net_sched: move TCQ_F_MQROOT into qdisc ops
  net_sched: use a flag to indicate fifo qdiscs instead of the name
  net_sched: forbid setting default qdisc to inappropriate ones
  net_sched: move ingress flag into qdisc ops

 include/net/sch_generic.h |  9 ++++++---
 net/sched/sch_api.c       | 40 +++++++++++++++++++++++++++-------------
 net/sched/sch_fifo.c      |  6 ++++--
 net/sched/sch_fq.c        |  1 +
 net/sched/sch_fq_codel.c  |  1 +
 net/sched/sch_generic.c   | 11 ++++++-----
 net/sched/sch_ingress.c   |  1 +
 net/sched/sch_mq.c        |  2 +-
 net/sched/sch_mqprio.c    |  2 +-
 net/sched/sch_sfq.c       |  1 +
 10 files changed, 49 insertions(+), 25 deletions(-)

-- 
1.8.3.1
