From: Chris Mi <chrism@mellanox.com>
Subject: [patch net v3 0/4] net/sched: Fix a system panic when deleting filters
Date: Mon, 16 Oct 2017 21:20:14 -0400
Message-ID: <1508203218-17998-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, lucasb@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40114 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755552AbdJQBU2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 21:20:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If some filters share the same action, when deleting these filters,
it is possible to create a system panic. This is because deletions
could be manipulated by many RCU callbacks at the same time.

This patch set fixes these issues. To reproduce the issue run selftests
in patch 3 and 4. To test if the issue was fixed, apply patches 1 and 2
and then repeat the tests.

v2 changelog
============

Revise the comment and add Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

v3 changelog
============
Add Acked-by: Lucas Bates <lucasb@mojatatu.com> for patch 3 and 4

Chris Mi (4):
  net/sched: Change tc_action refcnt and bindcnt to atomic
  net/sched: Use action array instead of action list as parameter
  selftests: Introduce a new script to generate tc batch file
  selftests: Introduce a new test case to tc testsuite

 include/net/act_api.h                              |  11 +-
 net/sched/act_api.c                                | 124 +++++++++++++--------
 net/sched/act_bpf.c                                |   4 +-
 net/sched/act_connmark.c                           |   4 +-
 net/sched/act_csum.c                               |   4 +-
 net/sched/act_gact.c                               |   4 +-
 net/sched/act_ife.c                                |   4 +-
 net/sched/act_ipt.c                                |   4 +-
 net/sched/act_mirred.c                             |   4 +-
 net/sched/act_nat.c                                |   4 +-
 net/sched/act_pedit.c                              |   4 +-
 net/sched/act_police.c                             |   4 +-
 net/sched/act_sample.c                             |   4 +-
 net/sched/act_simple.c                             |   4 +-
 net/sched/act_skbedit.c                            |   4 +-
 net/sched/act_skbmod.c                             |   4 +-
 net/sched/act_tunnel_key.c                         |   4 +-
 net/sched/act_vlan.c                               |   4 +-
 net/sched/cls_api.c                                |  18 +--
 .../tc-testing/tc-tests/filters/tests.json         |  23 +++-
 tools/testing/selftests/tc-testing/tdc.py          |  20 +++-
 tools/testing/selftests/tc-testing/tdc_batch.py    |  62 +++++++++++
 tools/testing/selftests/tc-testing/tdc_config.py   |   2 +
 23 files changed, 222 insertions(+), 102 deletions(-)
 create mode 100755 tools/testing/selftests/tc-testing/tdc_batch.py

-- 
1.8.3.1
