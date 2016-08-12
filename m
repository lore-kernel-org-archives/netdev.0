From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3 0/5] net_sched: tc action fixes and updates
Date: Thu, 11 Aug 2016 17:41:38 -0700
Message-ID: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36384 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbcHLAnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 20:43:52 -0400
Received: by mail-pf0-f177.google.com with SMTP id h186so3457647pfg.3
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 17:43:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes a few regressions caused by the previous
code refactor. Thanks to Jamal for catching them!

Note, patch 3/5 and 4/5 are not strictly necessary for this patchset,
I just want to carry them together.

---
v3: avoid list for fast path, suggested by Jamal

v2: replace flex_array with regular dynamic array
    keep tcf_action_stats_update() in act_api.h
    fix macro typos found by Amir

Cong Wang (5):
  net_sched: remove the leftover cleanup_a()
  net_sched: remove an unnecessary list_del()
  net_sched: fix a typo in tc_for_each_action()
  net_sched: move tc offload macros to pkt_cls.h
  net_sched: convert tcf_exts from list to pointer array

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c  |  4 +-
 include/net/act_api.h                           | 23 +++--------
 include/net/pkt_cls.h                           | 41 +++++++++++++++++---
 net/sched/act_api.c                             | 34 +++++------------
 net/sched/cls_api.c                             | 51 +++++++++++++++++--------
 7 files changed, 101 insertions(+), 68 deletions(-)

-- 
1.8.4.5
