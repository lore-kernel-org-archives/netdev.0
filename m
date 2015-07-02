From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/6] net_sched: act: lockless operation
Date: Thu,  2 Jul 2015 06:07:29 -0700
Message-ID: <1435842455-30501-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33875 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbbGBNHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 09:07:48 -0400
Received: by iebmu5 with SMTP id mu5so55830909ieb.1
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 06:07:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mentioned by Alexei last week in Budapest, it is a bit weird
to take a spinlock in order to drop a packet in a tc filter...

Lets add percpu infra for tc actions and use it for gact.

Before changes, my host with 8 RX queues was handling 5 Mpps,
and more than 10 Mpps after.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>

Eric Dumazet (6):
  net: sched: extend percpu stats helpers
  net: sched: add percpu stats to actions
  net_sched: act: make tcfg_pval non zero
  net_sched: act: use a separate packet counters for gact_determ()
  net_sched: act: read tcfg_ptype once
  net_sched: act: remove spinlock in fast path

 include/net/act_api.h        |  4 +++-
 include/net/sch_generic.h    | 27 +++++++++++++++++----------
 include/net/tc_act/tc_gact.h |  7 ++++---
 net/core/dev.c               |  4 ++--
 net/sched/act_api.c          | 44 ++++++++++++++++++++++++++++++++++----------
 net/sched/act_bpf.c          |  2 +-
 net/sched/act_connmark.c     |  3 ++-
 net/sched/act_csum.c         |  3 ++-
 net/sched/act_gact.c         | 35 ++++++++++++++++++-----------------
 net/sched/act_ipt.c          |  2 +-
 net/sched/act_mirred.c       |  3 ++-
 net/sched/act_nat.c          |  3 ++-
 net/sched/act_pedit.c        |  3 ++-
 net/sched/act_simple.c       |  3 ++-
 net/sched/act_skbedit.c      |  3 ++-
 net/sched/act_vlan.c         |  3 ++-
 16 files changed, 96 insertions(+), 53 deletions(-)

-- 
2.4.3.573.g4eafbef
