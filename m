From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/15]: Make use of new netlink API features
Date: Wed, 23 Jan 2008 17:36:35 +0100 (MET)
Message-ID: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49709 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518AbYAWQgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these patches change the packet schedulers/classifers/actions to make use
of the features of the new netlink API, like typeful attribute dumping and
parsing, automatic basic attribute validation etc. The also fix a bug and
a warning introduced by my last set of patches.

Please apply, thanks.


 include/linux/pkt_sched.h |    2 +
 include/net/act_api.h     |    4 +-
 net/sched/act_api.c       |  197 +++++++++++++++++++++++++--------------------
 net/sched/act_gact.c      |   20 +++--
 net/sched/act_ipt.c       |   33 +++++---
 net/sched/act_mirred.c    |   15 +++-
 net/sched/act_nat.c       |   15 +++-
 net/sched/act_pedit.c     |   15 +++-
 net/sched/act_police.c    |   43 +++++-----
 net/sched/act_simple.c    |   15 +++-
 net/sched/cls_api.c       |   30 ++++---
 net/sched/cls_basic.c     |   33 ++++----
 net/sched/cls_fw.c        |   41 +++++-----
 net/sched/cls_route.c     |   47 +++++------
 net/sched/cls_rsvp.h      |   45 +++++------
 net/sched/cls_tcindex.c   |   70 ++++++++--------
 net/sched/cls_u32.c       |   56 +++++++------
 net/sched/em_meta.c       |   18 +++--
 net/sched/ematch.c        |   31 +++++---
 net/sched/sch_api.c       |    7 +-
 net/sched/sch_atm.c       |   45 ++++++----
 net/sched/sch_cbq.c       |   75 +++++++----------
 net/sched/sch_dsmark.c    |   37 +++++----
 net/sched/sch_gred.c      |   28 +++++--
 net/sched/sch_hfsc.c      |   30 ++++---
 net/sched/sch_htb.c       |   64 ++++++++++-----
 net/sched/sch_ingress.c   |   12 ++--
 net/sched/sch_netem.c     |   73 +++++++---------
 net/sched/sch_prio.c      |    9 ++-
 net/sched/sch_red.c       |   16 +++-
 net/sched/sch_tbf.c       |   29 +++++---
 31 files changed, 650 insertions(+), 505 deletions(-)

Patrick McHardy (15):
      [NET_SCHED]: sch_atm: fix format string warning
      [NET_SCHED]: sch_netem: use nla_parse_nested_compat
      [NET_SCHED]: act_api: fix netlink API conversion bug
      [NET_SCHED]: act_api: use nlmsg_parse
      [NET_SCHED]: act_api: use PTR_ERR in tcf_action_init/tcf_action_get
      [NET_SCHED]: Propagate nla_parse return value
      [NET_SCHED]: Use nla_nest_start/nla_nest_end
      [NET_SCHED]: Use NLA_PUT_STRING for string dumping
      [NET_SCHED]: Use typeful attribute construction helpers
      [NET_SCHED]: Use typeful attribute parsing helpers
      [NET_SCHED]: sch_api: introduce constant for rate table size
      [NET_SCHED]: Use nla_policy for attribute validation in packet schedulers
      [NET_SCHED]: Use nla_policy for attribute validation in classifiers
      [NET_SCHED]: Use nla_policy for attribute validation in actions
      [NET_SCHED]: Use nla_policy for attribute validation in ematches
