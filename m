From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v4 0/7] net_sched: tc action fixes and updates
Date: Sat, 13 Aug 2016 22:34:55 -0700
Message-ID: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33525 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbcHNJ0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 05:26:44 -0400
Received: by mail-pf0-f180.google.com with SMTP id y134so8932041pfg.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 02:26:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes a few regressions caused by the previous
code refactor and more. Thanks to Jamal for catching them!

Note, patch 3/7 and 4/7 are not strictly necessary for this patchset,
I just want to carry them together.

---
v4: adjust an indention for Jamal
    add two more patches

v3: avoid list for fast path, suggested by Jamal

v2: replace flex_array with regular dynamic array
    keep tcf_action_stats_update() in act_api.h
    fix macro typos found by Amir

Cong Wang (7):
  net_sched: remove the leftover cleanup_a()
  net_sched: remove an unnecessary list_del()
  net_sched: fix a typo in tc_for_each_action()
  net_sched: move tc offload macros to pkt_cls.h
  net_sched: convert tcf_exts from list to pointer array
  net_sched: unify the init logic for act_police
  net_sched: allow flushing tc police actions

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 +++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c  |  4 +-
 include/net/act_api.h                           | 23 ++-------
 include/net/pkt_cls.h                           | 41 ++++++++++++++--
 net/sched/act_api.c                             | 34 ++++----------
 net/sched/act_police.c                          | 62 +++++--------------------
 net/sched/cls_api.c                             | 51 ++++++++++++++------
 8 files changed, 112 insertions(+), 119 deletions(-)

-- 
1.8.4.5
