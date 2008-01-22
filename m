From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/06]: Conversion to new netlink API
Date: Tue, 22 Jan 2008 15:56:08 +0100 (MET)
Message-ID: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50731 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbYAVO4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:56:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches convert the packet schedulers to the new netlink API.
This will allow to use the new features like automatic attribute
checking and gets rid of the largest rtnetlink.h user we still have.
Unfortunately a gradual conversion is not really feasible, so the
patches are quite large, but most of them has been generated
automatically, so I'm pretty sure they are correct and didn't miss
anything. Also included are some minor unrelated cleanups I had
queued in the same tree.

Please apply, thanks.


 include/net/act_api.h      |    8 +-
 include/net/gen_stats.h    |    6 +-
 include/net/netlink.h      |    3 +
 include/net/pkt_cls.h      |   10 +-
 include/net/pkt_sched.h    |    2 +-
 include/net/sch_generic.h  |    8 +-
 net/core/gen_estimator.c   |    8 +-
 net/core/gen_stats.c       |    9 +-
 net/mac80211/wme.c         |   14 ++--
 net/netfilter/xt_RATEEST.c |    7 +-
 net/netlink/attr.c         |   19 ++++
 net/sched/act_api.c        |  221 ++++++++++++++++++++++----------------------
 net/sched/act_gact.c       |   28 +++---
 net/sched/act_ipt.c        |   46 +++++-----
 net/sched/act_mirred.c     |   18 ++--
 net/sched/act_nat.c        |   18 ++--
 net/sched/act_pedit.c      |   20 ++--
 net/sched/act_police.c     |   50 +++++-----
 net/sched/act_simple.c     |   24 +++---
 net/sched/cls_api.c        |   65 +++++++------
 net/sched/cls_basic.c      |   42 ++++----
 net/sched/cls_fw.c         |   57 ++++++------
 net/sched/cls_route.c      |   73 +++++++--------
 net/sched/cls_rsvp.h       |   48 +++++-----
 net/sched/cls_tcindex.c    |   69 +++++++-------
 net/sched/cls_u32.c        |   81 ++++++++--------
 net/sched/em_meta.c        |   56 ++++++------
 net/sched/em_text.c        |    9 +-
 net/sched/ematch.c         |   85 +++++++++---------
 net/sched/sch_api.c        |   96 +++++++++++---------
 net/sched/sch_atm.c        |   48 +++++-----
 net/sched/sch_cbq.c        |  156 ++++++++++++++++----------------
 net/sched/sch_dsmark.c     |   85 ++++++++++-------
 net/sched/sch_fifo.c       |   13 +--
 net/sched/sch_generic.c    |   23 ++---
 net/sched/sch_gred.c       |   59 +++++++------
 net/sched/sch_hfsc.c       |   72 +++++++-------
 net/sched/sch_htb.c        |   68 +++++++-------
 net/sched/sch_ingress.c    |   14 ++--
 net/sched/sch_netem.c      |  100 ++++++++++----------
 net/sched/sch_prio.c       |   30 ++++---
 net/sched/sch_red.c        |   52 ++++++-----
 net/sched/sch_sfq.c        |   12 +-
 net/sched/sch_tbf.c        |   49 +++++-----
 net/sched/sch_teql.c       |    2 +-
 45 files changed, 1022 insertions(+), 961 deletions(-)

Patrick McHardy (6):
      [NET_SCHED]: Move EXPORT_SYMBOL next to exported symbol
      [NET_SCHED]: mark classifier ops __read_mostly
      [NETLINK]: Add nla_append()
      [NET_SCHED]: Convert packet schedulers from rtnetlink to new netlink API
      [NET_SCHED]: Convert classifiers from rtnetlink to new netlink API
      [NET_SCHED]: Convert actions from rtnetlink to new netlink API
