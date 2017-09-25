From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: Introduce support for "pass" gact action offloading
Date: Mon, 25 Sep 2017 10:58:19 +0200
Message-ID: <20170925085822.1358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36263 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932107AbdIYI6Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:58:24 -0400
Received: by mail-wr0-f195.google.com with SMTP id g50so1510123wra.3
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:58:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Very simple patchset adds ability for user to insert filters with "pass"
gact action and offload it. That allows scenarios like this:

$ tc filter add dev enp3s0np19 ingress protocol ip pref 10 flower skip_sw dst_ip 192.168.101.0/24 action drop
$ tc filter add dev enp3s0np19 ingress protocol ip pref 9 flower skip_sw dst_ip 192.168.101.1 action pass

Jiri Pirko (3):
  mlxsw: spectrum_acl: Propagate errors from
    mlxsw_afa_block_jump/continue
  net: sched: introduce helper to identify gact pass action
  mlxsw: spectrum_flower: Offload "ok" termination action

 .../net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c    | 14 ++++++++------
 .../net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h    |  4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h             |  6 +++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c         | 10 +++++-----
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  6 +++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c      | 10 ++++++++--
 include/net/tc_act/tc_gact.h                               |  5 +++++
 7 files changed, 36 insertions(+), 19 deletions(-)

-- 
2.9.5
