From: Chris Mi <chrism@mellanox.com>
Subject: [patch net 0/4] net/sched: Fix a system panic when deleting filters
Date: Mon, 16 Oct 2017 04:31:38 -0400
Message-ID: <1508142702-3312-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, lucasb@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50052 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751780AbdJPIbr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 04:31:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If some filters share the same action, when deleting these filters,
system may panic. This patchset fixes this issue. And the test case
finding this issue is also integrated into tc test suite of selftests.

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
