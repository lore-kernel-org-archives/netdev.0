From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/6] introduce trap control action to tc and offload it
Date: Tue,  6 Jun 2017 14:12:01 +0200
Message-ID: <20170606121207.2921-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36793 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdFFMML (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:12:11 -0400
Received: by mail-wm0-f46.google.com with SMTP id 7so96088095wmo.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 05:12:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces a control action dedicated to indicate
to trap the matched packet to CPU. This is specific action for
HW offloads. Also, the patchset offloads the action to mlxsw driver.

Example usage:
$ tc filter add dev enp3s0np19 parent ffff: protocol ip prio 20 flower skip_sw dst_ip 192.168.10.1 action trap

---
v1->v2:
- patch 1
  - fix the comment according to Andrew's note

Jiri Pirko (6):
  net: sched: introduce a TRAP control action
  net: sched: introduce helper to identify gact trap action
  mlxsw: pci: Fix size of trap_id field in CQE
  mlxsw: spectrum: Introduce ACL trap
  acl: Introduce ACL trap action
  spectrum_flower: Implement gact trap TC action offload

 .../mellanox/mlxsw/core_acl_flex_actions.c         | 40 ++++++++++++++++++++--
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  1 +
 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h       |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  4 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |  5 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  4 +++
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |  1 +
 include/net/tc_act/tc_gact.h                       | 15 ++++++--
 include/uapi/linux/pkt_cls.h                       |  7 ++++
 net/core/dev.c                                     |  2 ++
 net/sched/cls_bpf.c                                |  1 +
 net/sched/sch_atm.c                                |  1 +
 net/sched/sch_cbq.c                                |  1 +
 net/sched/sch_drr.c                                |  1 +
 net/sched/sch_dsmark.c                             |  1 +
 net/sched/sch_fq_codel.c                           |  1 +
 net/sched/sch_hfsc.c                               |  1 +
 net/sched/sch_htb.c                                |  1 +
 net/sched/sch_multiq.c                             |  1 +
 net/sched/sch_prio.c                               |  1 +
 net/sched/sch_qfq.c                                |  1 +
 net/sched/sch_sfb.c                                |  1 +
 net/sched/sch_sfq.c                                |  1 +
 24 files changed, 89 insertions(+), 6 deletions(-)

-- 
2.9.3
