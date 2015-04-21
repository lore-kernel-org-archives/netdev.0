From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC 0/3] tc cleanup?
Date: Tue, 21 Apr 2015 12:27:53 -0700
Message-ID: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35722 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977AbbDUT2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 15:28:10 -0400
Received: by pdbqd1 with SMTP id qd1so251175218pdb.2
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 12:28:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've started cleaning TC a bit.
Before I go too far, need your feedback on this RFC:

patch 1 - stop abuse of return values in ingress qdisc
patch 2 - deprecate TC_ACT_QUEUED
patch 3 - reduce copy-paste around tc_classify()

Lightly tested so far. Waiting for John's and other tc test scripts.

Alexei Starovoitov (3):
  tc: fix return values of ingress qdisc
  tc: deprecate TC_ACT_QUEUED
  tc: cleanup tc_classify

 include/net/pkt_sched.h      |    2 ++
 include/net/sch_generic.h    |    7 +++++++
 include/uapi/linux/pkt_cls.h |    2 +-
 net/core/dev.c               |    8 ++------
 net/sched/sch_api.c          |   22 ++++++++++++++++++++++
 net/sched/sch_atm.c          |    1 -
 net/sched/sch_cbq.c          |    1 -
 net/sched/sch_choke.c        |   17 +++--------------
 net/sched/sch_drr.c          |   18 +++---------------
 net/sched/sch_dsmark.c       |    1 -
 net/sched/sch_fq_codel.c     |   25 ++++++-------------------
 net/sched/sch_hfsc.c         |    1 -
 net/sched/sch_htb.c          |    1 -
 net/sched/sch_ingress.c      |   10 ++++------
 net/sched/sch_multiq.c       |    1 -
 net/sched/sch_prio.c         |    1 -
 net/sched/sch_qfq.c          |   16 ++--------------
 net/sched/sch_sfb.c          |   17 +++--------------
 net/sched/sch_sfq.c          |   26 ++++++--------------------
 19 files changed, 61 insertions(+), 116 deletions(-)

-- 
1.7.9.5
