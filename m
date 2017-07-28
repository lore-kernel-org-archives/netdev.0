From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/20] net: sched: summer cleanup part 1, mainly in exts area
Date: Fri, 28 Jul 2017 16:40:22 +0200
Message-ID: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35006 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751761AbdG1Okp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:40:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id r77so14579703wmd.2
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:40:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset is one of the couple cleanup patchsets I have in queue.
The motivation aside the obvious need to "make things nicer" is also
to prepare for shared filter blocks introduction. That requires tp->q
removal, and therefore removal of all tp->q users.

Patch 1 is just some small thing I spotted on the way
Patch 2 removes one user of tp->q, namely tcf_em_tree_change
Patches 3-8 do preparations for exts->nr_actions removal
Patch 9 does the conversion of action array into rcuized list. This is also
        one tp->q user removal.
Patches 10-11 do simple renames of functions in cls*
The rest of the patches remove unnecessary calls of tcf_exts_change helper.

Tested by tools/testing/selftests/tc-testing

Jiri Pirko (20):
  net: sched: sch_atm: use Qdisc_class_common structure
  net: sched: remove unneeded tcf_em_tree_change
  net: sched: change names of action number helpers to be aligned with
    the rest
  net: sched: use tcf_exts_has_actions in tcf_exts_exec
  net: sched: remove redundant helpers tcf_exts_is_predicative and
    tcf_exts_is_available
  net: sched: fix return value of tcf_exts_exec
  net: sched: remove check for number of actions in tcf_exts_exec
  net: sched: use tcf_exts_has_actions instead of exts->nr_actions
  net: sched: convert actions array into rcu list
  net: sched: cls_bpf: rename cls_bpf_modify_existing function
  net: sched: cls_fw: rename fw_change_attrs function
  net: sched: cls_flower: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_fw: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_matchall: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_basic: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_bpf: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_cgroup: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_flow: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_route: no need to call tcf_exts_change for newly
    allocated struct
  net: sched: cls_u32: no need to call tcf_exts_change for newly
    allocated struct

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |   2 +-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   |   4 +-
 include/net/act_api.h                              |  11 +-
 include/net/pkt_cls.h                              | 143 ++++++++-------------
 net/dsa/slave.c                                    |   2 +-
 net/sched/act_api.c                                |  17 ++-
 net/sched/cls_api.c                                |  35 +++--
 net/sched/cls_basic.c                              |  21 +--
 net/sched/cls_bpf.c                                |  39 ++----
 net/sched/cls_cgroup.c                             |  22 +---
 net/sched/cls_flow.c                               |  48 +++----
 net/sched/cls_flower.c                             |  17 +--
 net/sched/cls_fw.c                                 |  44 ++-----
 net/sched/cls_matchall.c                           |  19 +--
 net/sched/cls_route.c                              |  36 ++----
 net/sched/cls_rsvp.h                               |  18 +--
 net/sched/cls_tcindex.c                            |  55 +++-----
 net/sched/cls_u32.c                                |  27 +---
 net/sched/sch_atm.c                                |  12 +-
 23 files changed, 192 insertions(+), 390 deletions(-)

-- 
2.9.3
