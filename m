From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 00/11] couple of net/sched fixes+improvements
Date: Sun, 10 Feb 2013 11:52:08 +0100
Message-ID: <1360493539-14868-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:41545 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932Ab3BJKwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:52:31 -0500
Received: by mail-ea0-f169.google.com with SMTP id d13so2242425eaa.14
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 02:52:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
  tbf: improved accuracy at high rates
  tbf: ignore max_size check for gso skbs
  tbf: fix value set for q->ptokens
  act_police: move struct tcf_police to act_police.c
  act_police: improved accuracy at high rates
  act_police: remove <=mtu check for gso skbs

 include/net/act_api.h     |  15 -------
 include/net/sch_generic.h |  19 +++++++++
 net/sched/act_police.c    | 100 ++++++++++++++++++++++++++++------------------
 net/sched/sch_generic.c   |  37 +++++++++++++++++
 net/sched/sch_htb.c       |  80 +++++++------------------------------
 net/sched/sch_tbf.c       |  73 ++++++++++++++++-----------------
 6 files changed, 169 insertions(+), 155 deletions(-)

-- 
1.8.1.2
