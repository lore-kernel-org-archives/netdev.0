From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] introduce trap control action to tc and offload it
Date: Mon,  5 Jun 2017 16:38:26 +0200
Message-ID: <20170605143832.7025-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:34487 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdFEOif (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 10:38:35 -0400
Received: by mail-wr0-f182.google.com with SMTP id g76so39455373wrd.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 07:38:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces a control action dedicated to indicate
to trap the matched packet to CPU. This is specific action for
HW offloads. Also, the patchset offloads the action to mlxsw driver.

Example usage:
$ tc filter add dev enp3s0np19 parent ffff: protocol ip prio 20 flower skip_sw dst_ip 192.168.10.1 action trap

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
 include/uapi/linux/pkt_cls.h                       |  5 +++
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
 24 files changed, 87 insertions(+), 6 deletions(-)

-- 
2.9.3
