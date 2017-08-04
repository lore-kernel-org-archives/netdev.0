From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/20] net: sched: summer cleanup part 1, mainly in exts area
Date: Fri,  4 Aug 2017 14:28:55 +0200
Message-ID: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:38742 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdHDM3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:18 -0400
Received: by mail-wm0-f65.google.com with SMTP id y206so5509413wmd.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:17 -0700 (PDT)
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
Patches 9-10 do simple renames of functions in cls*
Patches 11-19 remove unnecessary calls of tcf_exts_change helper
The last patch changes tcf_exts_change to don't take lock

Tested by tools/testing/selftests/tc-testing

v1->v2:
- removed conversion of action array to list as noted by Cong
- added the past patch instead
- small rebases of patches 11-19

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
  net: sched: avoid atomic swap in tcf_exts_change

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |   2 +-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   |   4 +-
 include/net/pkt_cls.h                              | 106 +++++++--------------
 net/dsa/slave.c                                    |   2 +-
 net/sched/act_api.c                                |   3 +-
 net/sched/cls_api.c                                |  14 +--
 net/sched/cls_basic.c                              |  17 +---
 net/sched/cls_bpf.c                                |  35 ++-----
 net/sched/cls_cgroup.c                             |  18 +---
 net/sched/cls_flow.c                               |  47 ++++-----
 net/sched/cls_flower.c                             |  13 +--
 net/sched/cls_fw.c                                 |  34 +++----
 net/sched/cls_matchall.c                           |  14 +--
 net/sched/cls_route.c                              |  32 ++-----
 net/sched/cls_rsvp.h                               |   4 +-
 net/sched/cls_tcindex.c                            |   8 +-
 net/sched/cls_u32.c                                |  18 +---
 net/sched/sch_atm.c                                |  12 +--
 22 files changed, 125 insertions(+), 268 deletions(-)

-- 
2.9.3
