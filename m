From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v3 0/4] net_sched: update backlog for hierarchical qdisc's
Date: Thu, 25 Feb 2016 14:54:59 -0800
Message-ID: <1456440903-32335-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35319 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbcBYWzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:55:11 -0500
Received: by mail-pa0-f47.google.com with SMTP id ho8so40690297pac.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 14:55:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For hierarchical qdisc like HTB, we currently only update its qlen
but leave its backlog as zero:

    qdisc htb 1: dev eth0 root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17
     Sent 172680457356 bytes 222469449 pkt (dropped 0, overlimits 123575834 requeues 0)
     backlog 0b 72p requeues 0

This patchset makes backlog as accurate as qlen.

---
v3: rebase and fix the n==0 case for qdisc_tree_reduce_backlog()
v2: rebase and update changelog, not code change

Cong Wang (4):
  net_sched: introduce qdisc_replace() helper
  net_sched: update hierarchical backlog too
  sch_htb: update backlog as well
  sch_dsmark: update backlog as well

 include/net/codel.h       |  4 ++++
 include/net/sch_generic.h | 20 +++++++++++++++++++-
 net/sched/sch_api.c       |  8 +++++---
 net/sched/sch_cbq.c       | 12 ++++--------
 net/sched/sch_choke.c     |  6 ++++--
 net/sched/sch_codel.c     | 10 ++++++----
 net/sched/sch_drr.c       |  9 +++------
 net/sched/sch_dsmark.c    | 11 ++++-------
 net/sched/sch_fq.c        |  4 +++-
 net/sched/sch_fq_codel.c  | 17 ++++++++++++-----
 net/sched/sch_hfsc.c      |  9 +++------
 net/sched/sch_hhf.c       | 10 +++++++---
 net/sched/sch_htb.c       | 24 +++++++++++-------------
 net/sched/sch_multiq.c    | 16 ++++++----------
 net/sched/sch_netem.c     | 13 +++----------
 net/sched/sch_pie.c       |  5 +++--
 net/sched/sch_prio.c      | 15 +++++----------
 net/sched/sch_qfq.c       |  9 +++------
 net/sched/sch_red.c       | 10 +++-------
 net/sched/sch_sfb.c       | 10 +++-------
 net/sched/sch_sfq.c       | 16 +++++++++-------
 net/sched/sch_tbf.c       | 15 ++++++---------
 22 files changed, 126 insertions(+), 127 deletions(-)

-- 
2.1.0
