From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/9] net: sched: remove some tp->q usage
Date: Fri, 13 Oct 2017 14:00:56 +0200
Message-ID: <20171013120105.23358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33004 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753413AbdJMMBI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 08:01:08 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so5615774wmu.0
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 05:01:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In order to prepare for block sharing, tcf_proto instances need to be
independent on particular qdisc instances. This patchset takes care of
removal of couple occurrences of tp->q usage.

Jiri Pirko (9):
  net: sched: store Qdisc pointer in struct block
  net: sched: store net pointer in block and introduce qdisc_net helper
  net: sched: introduce tcf_block_q and tcf_block_dev helpers
  net: sched: teach tcf_bind/unbind_filter to use block->q
  net: sched: ematch: obtain net pointer from blocks
  net: sched: cls_u32: use block instead of q in tc_u_common
  net: sched: tcindex, fw, flow: use tcf_block_q helper to get struct
    Qdisc
  net: sched: use tcf_block_q helper to get q pointer for sch_tree_lock
  net: sched: propagate q and parent from caller down to tcf_fill_node

 include/net/pkt_cls.h     | 52 +++++++++++++++++++++++++++++++----------
 include/net/pkt_sched.h   |  7 ++++++
 include/net/sch_generic.h |  5 ++--
 net/sched/cls_api.c       | 59 ++++++++++++++++++++++++++++++-----------------
 net/sched/cls_flow.c      |  7 ++++--
 net/sched/cls_fw.c        |  5 +++-
 net/sched/cls_tcindex.c   |  5 +++-
 net/sched/cls_u32.c       | 12 ++++------
 net/sched/ematch.c        |  2 +-
 net/sched/sch_api.c       |  6 +++--
 net/sched/sch_atm.c       |  4 ++--
 net/sched/sch_cbq.c       |  2 +-
 net/sched/sch_drr.c       |  2 +-
 net/sched/sch_dsmark.c    |  2 +-
 net/sched/sch_fq_codel.c  |  2 +-
 net/sched/sch_hfsc.c      |  4 ++--
 net/sched/sch_htb.c       |  4 ++--
 net/sched/sch_ingress.c   |  6 ++---
 net/sched/sch_multiq.c    |  2 +-
 net/sched/sch_prio.c      |  2 +-
 net/sched/sch_qfq.c       |  2 +-
 net/sched/sch_sfb.c       |  2 +-
 net/sched/sch_sfq.c       |  2 +-
 23 files changed, 127 insertions(+), 69 deletions(-)

-- 
2.9.5
