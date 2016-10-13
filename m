From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v4 net-next 0/4] act_mirred: Ingress actions support
Date: Thu, 13 Oct 2016 09:06:40 +0300
Message-ID: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33472 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933749AbcJMGHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 02:07:51 -0400
Received: by mail-pf0-f193.google.com with SMTP id i85so904871pfa.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 23:07:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements action mirred 'ingress' actions
TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.

This allows attaching filters whose target is to hand matching skbs into
the rx processing of a specified device.

v4:
  in 4/4, check ret code of netif_receive_skb, as suggested by Cong Wang
v3:
  in 4/4, addressed non coherency due to reading m->tcfm_eaction multiple
  times, as spotted by Eric Dumazet
v2:
  in 1/4, declare tcfm_mac_header_xmit as bool instead of int

Shmulik Ladkani (4):
  net/sched: act_mirred: Rename tcfm_ok_push to tcfm_mac_header_xmit and
    make it a bool
  net/sched: act_mirred: Refactor detection whether dev needs xmit at
    mac header
  net/sched: tc_mirred: Rename public predicates
    'is_tcf_mirred_redirect' and 'is_tcf_mirred_mirror'
  net/sched: act_mirred: Implement ingress actions

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  4 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  2 +-
 include/net/tc_act/tc_mirred.h                     |  6 +-
 net/sched/act_mirred.c                             | 84 ++++++++++++++++------
 7 files changed, 73 insertions(+), 29 deletions(-)

-- 
1.9.1
