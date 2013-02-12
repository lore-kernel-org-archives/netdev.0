From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 00/11] couple of net/sched fixes+improvements
Date: Tue, 12 Feb 2013 11:11:58 +0100
Message-ID: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:42700 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527Ab3BLKMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:12:17 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so3777361eek.23
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:12:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4->v5:
 - added patch "sch_api: introduce qdisc_watchdog_schedule_ns()"
 - remove bogus patch "tbf: fix value set for q->ptokens"
 - fixed watchdog scheduling
   (patch "tbf: improved accuracy at high rates")
 - fixed q->mtu handling
   (patch "tbf: improved accuracy at high rates")
 - added gso skb checks to "peak" branches
   (patch "tbf: take into account gso skbs" and
    patch "act_police: remove <=mtu check for gso skbs")

v3->v4:
 - cache mtu_ptokens value instead of compute in by psched_l2t_ns in fast path
   (patch "act_police: improved accuracy at high rates" and
    patch "tbf: fix value set for q->ptokens")

v2->v3:
 - fixed schedule while atomic issue
   (patch "act_police: improved accuracy at high rates")

v1->v2:
 - made struct psched_ratecfg const in params of couple of inline functions
   (patch "sch: make htb_rate_cfg and functions around that generic")
 - fixes misspelled "peak"
   (patch "tbf: improved accuracy at high rates")
 - added last 4 patches to this set

Jiri Pirko (11):
  htb: use PSCHED_TICKS2NS()
  htb: fix values in opt dump
  htb: remove pointless first initialization of buffer and cbuffer
  htb: initialize cl->tokens and cl->ctokens correctly
  sch: make htb_rate_cfg and functions around that generic
  sch_api: introduce qdisc_watchdog_schedule_ns()
  tbf: improved accuracy at high rates
  act_police: move struct tcf_police to act_police.c
  act_police: improved accuracy at high rates
  tbf: take into account gso skbs
  act_police: remove <=mtu check for gso skbs

 include/net/act_api.h     |  15 -------
 include/net/pkt_sched.h   |  10 ++++-
 include/net/sch_generic.h |  19 +++++++++
 net/sched/act_police.c    | 102 ++++++++++++++++++++++++++++------------------
 net/sched/sch_api.c       |   6 +--
 net/sched/sch_generic.c   |  37 +++++++++++++++++
 net/sched/sch_htb.c       |  80 +++++++-----------------------------
 net/sched/sch_tbf.c       |  78 +++++++++++++++++------------------
 8 files changed, 182 insertions(+), 165 deletions(-)

-- 
1.8.1.2
