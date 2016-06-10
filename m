From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] net_sched: remove qdisc_is_throttled()
Date: Fri, 10 Jun 2016 16:41:35 -0700
Message-ID: <1465602099-15808-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36821 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbcFJXln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 19:41:43 -0400
Received: by mail-pa0-f53.google.com with SMTP id b5so27758755pas.3
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 16:41:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HTB, CBQ and HFSC pay a very high cost updating the qdisc 'throttled'
status that nothing but CBQ seems to use.

CBQ usage is flaky anyway, since no qdisc ->enqueue() updates the
'throttled' qdisc status.

This looks like some 'optimization' that actually cost more than code
without the optimization, and might cause latency issues with CBQ.

In my tests, I could achieve a 8 % performance increase in TCP_RR
workload through HTB qdisc, in presence of throttled classes,
and 5 % without throttled classes.

Eric Dumazet (4):
  net_sched: sch_plug: use a private throttled status
  net_sched: cbq: remove a flaky use of qdisc_is_throttled()
  net_sched: netem: remove qdisc_is_throttled() use
  net_sched: remove generic throttled management

 include/net/pkt_sched.h   |  4 ++--
 include/net/sch_generic.h | 16 ----------------
 net/sched/sch_api.c       |  7 +------
 net/sched/sch_cbq.c       |  4 +---
 net/sched/sch_fq.c        |  3 +--
 net/sched/sch_hfsc.c      |  1 -
 net/sched/sch_htb.c       |  3 +--
 net/sched/sch_netem.c     |  4 ----
 net/sched/sch_plug.c      | 14 ++++++++------
 net/sched/sch_tbf.c       |  4 +---
 10 files changed, 15 insertions(+), 45 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
