From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] net: sched: get rid of cls_flower->egress_dev
Date: Tue, 10 Oct 2017 09:30:12 +0200
Message-ID: <20171010073016.3682-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38397 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755157AbdJJHaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 03:30:18 -0400
Received: by mail-wm0-f68.google.com with SMTP id q124so24026545wmb.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 00:30:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduction of cls_flower->egress_dev was a workaround. Turned out
to be a bit ugly hack. So replace it with more generic and reusable
infrastructure.

This is a dependency of shared block introduction that will be send as
a follow-up patchsets group.

Jiri Pirko (4):
  net: sched: make tc_action_ops->get_dev return dev and avoid passing
    net
  net: sched: introduce per-egress action device callbacks
  net: sched: convert cls_flower->egress_dev users to tc_setup_cb_egdev
    infra
  net: sched: remove unused tcf_exts_get_dev helper and
    cls_flower->egress_dev

 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  |  31 ++--
 include/net/act_api.h                             |  37 +++-
 include/net/pkt_cls.h                             |   6 +-
 include/net/tc_act/tc_mirred.h                    |   1 +
 net/sched/act_api.c                               | 203 ++++++++++++++++++++++
 net/sched/act_mirred.c                            |  13 +-
 net/sched/cls_api.c                               |  35 ++--
 net/sched/cls_flower.c                            |  63 +++----
 10 files changed, 331 insertions(+), 65 deletions(-)

-- 
2.9.5
