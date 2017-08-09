From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] net: sched: let the offloader decide what to offload
Date: Wed,  9 Aug 2017 14:30:30 +0200
Message-ID: <20170809123035.7663-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, oss-drivers@netronome.com,
        ganeshgr@chelsio.com, jeffrey.t.kirsher@intel.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36643 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbdHIMaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:30:39 -0400
Received: by mail-wr0-f194.google.com with SMTP id y67so4390181wrb.3
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:30:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently there is a Qdisc_class_ops->tcf_cl_offload callback
that is called to find out if cls would offload rule or not.
This is only supported by sch_ingress and sch_clsact.
So the Qdisc are to decide. However, the driver knows what is he
able to offload, so move the decision making to drivers completely.
Just pass classid there and provide set of helpers to allow
identification of qdisc.

As a side effect, this actually allows clsact egress rules
offload in mlxsw.

Jiri Pirko (5):
  net: sched: Add helpers to identify classids
  net: sched: propagate classid down to offload drivers
  net: sched: use newly added classid identity helpers
  net: sched: remove handle propagation down to the drivers
  net: sched: remove cops->tcf_cl_offload

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c      | 18 ++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/bpf/main.c       |  2 +-
 drivers/net/ethernet/netronome/nfp/flower/offload.c |  2 +-
 include/net/pkt_cls.h                               | 18 +++++-------------
 include/net/pkt_sched.h                             | 14 ++++++++++++++
 include/net/sch_generic.h                           |  1 -
 net/dsa/slave.c                                     |  9 ++++++++-
 net/sched/cls_bpf.c                                 |  4 ++--
 net/sched/cls_flower.c                              |  8 ++++----
 net/sched/cls_matchall.c                            |  4 ++--
 net/sched/cls_u32.c                                 |  8 ++++----
 net/sched/sch_ingress.c                             | 12 ------------
 16 files changed, 61 insertions(+), 47 deletions(-)

-- 
2.9.3
