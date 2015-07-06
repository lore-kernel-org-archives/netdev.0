From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/7] net_sched: act: lockless operation
Date: Sun,  5 Jul 2015 23:41:25 -0700
Message-ID: <1436164896-8243-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35353 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbGFGlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 02:41:47 -0400
Received: by iecuq6 with SMTP id uq6so107280102iec.2
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 23:41:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mentioned by Alexei last week in Budapest, it is a bit weird
to take a spinlock in order to drop a packet in a tc filter...

Lets add percpu infra for tc actions and use it for gact & mirred.

Before changes, my host with 8 RX queues was handling 5 Mpps with gact,
and more than 11 Mpps after.

Mirred change is not yet visible if ifb+qdisc is used, as ifb is
not yet multi queue enabled, but is a step forward.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>

Eric Dumazet (7):
  net: sched: extend percpu stats helpers
  net: sched: add percpu stats to actions
  net_sched: act_gact: make tcfg_pval non zero
  net_sched: act_gact: use a separate packet counters for gact_determ()
  net_sched: act_gact: read tcfg_ptype once
  net_sched: act_gact: remove spinlock in fast path
  net_sched: act_mirred: remove spinlock in fast path

 include/net/act_api.h          | 15 ++++++++++-
 include/net/sch_generic.h      | 31 ++++++++++++++--------
 include/net/tc_act/tc_gact.h   |  7 ++---
 include/net/tc_act/tc_mirred.h |  2 +-
 net/core/dev.c                 |  4 +--
 net/sched/act_api.c            | 44 ++++++++++++++++++++++++--------
 net/sched/act_bpf.c            |  2 +-
 net/sched/act_connmark.c       |  3 ++-
 net/sched/act_csum.c           |  3 ++-
 net/sched/act_gact.c           | 44 ++++++++++++++++++--------------
 net/sched/act_ipt.c            |  2 +-
 net/sched/act_mirred.c         | 58 ++++++++++++++++++++++--------------------
 net/sched/act_nat.c            |  3 ++-
 net/sched/act_pedit.c          |  3 ++-
 net/sched/act_simple.c         |  3 ++-
 net/sched/act_skbedit.c        |  3 ++-
 net/sched/act_vlan.c           |  3 ++-
 17 files changed, 148 insertions(+), 82 deletions(-)

-- 
2.4.3.573.g4eafbef
